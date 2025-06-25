/***************************************************/
/* Traffic Light Controller                        */
/* FSM-based light sequencing with pedestrian mode */
/***************************************************/

module traffic # (
    parameter CYCLES_PER_SEC = 125000000 // Clock cycles per 1 second
)(
    input  clk,                 // Clock signal
    input  i_maintenance,       // Reset/maintenance trigger
    input  [3:0] i_ped_buttons, // Pedestrian request buttons
    output [2:0] o_light_ns,    // North-South traffic light {red, yellow, green}
    output [2:0] o_light_ew,    // East-West traffic light {red, yellow, green}
    output       o_light_ped    // Pedestrian crossing light
);

// Traffic light color encodings
localparam GREEN_LIGHT  = 3'b010;
localparam YELLOW_LIGHT = 3'b110;
localparam RED_LIGHT    = 3'b100;

// Output registers controlled by FSM
logic [2:0] r_light_ns, r_light_ew;
logic       r_light_ped;

// Timing constants and FSM state declaration
localparam QUARTER_SEC_CYCLES = CYCLES_PER_SEC / 4;
enum {NS_G, NS_Y, EW_G, EW_Y, PED_CROSS, PED_BLINK} state, next_state;

// Internal state-tracking signals
logic [3:0]  time_count;
logic [27:0] cycle_count;
logic        ped_flag;
logic        ped_blink_toggle;

// Synchronous state transitions and timing updates
always_ff @(posedge clk) begin
    // Set or clear pedestrian request flag
    if (state == PED_CROSS || state == PED_BLINK)
        ped_flag <= 0;
    else if (i_ped_buttons != 0)
        ped_flag <= 1;

    // Maintenance reset logic
    if (i_maintenance) begin
        time_count        <= 0;
        cycle_count       <= 0;
        state             <= NS_G;
        ped_flag          <= 0;
        ped_blink_toggle  <= 0;
    end else begin
        // Cycle-based state progression
        if (cycle_count == CYCLES_PER_SEC - 1) begin
            cycle_count <= 0;
            if (next_state == NS_G && state != next_state)
                time_count <= 0;
            else
                time_count <= time_count + 1;
            state <= next_state;
        end else begin
            cycle_count <= cycle_count + 1;
        end

        // Blink pedestrian light at quarter-second intervals
        if (state == PED_BLINK) begin
            if (cycle_count == QUARTER_SEC_CYCLES - 1 ||
                cycle_count == (2 * QUARTER_SEC_CYCLES) - 1 ||
                cycle_count == (3 * QUARTER_SEC_CYCLES) - 1 ||
                cycle_count == (4 * QUARTER_SEC_CYCLES) - 1)
                ped_blink_toggle <= ~ped_blink_toggle;
        end else begin
            ped_blink_toggle <= 0;
        end
    end
end

// Combinational next-state logic
always_comb begin: state_decoder
    case (state)
        NS_G:       next_state = (time_count == 2) ? NS_Y       : NS_G;
        NS_Y:       next_state = (time_count == 4) ? EW_G       : NS_Y;
        EW_G:       next_state = (time_count == 7) ? EW_Y       : EW_G;
        EW_Y:       next_state = (time_count == 9) ? (ped_flag ? PED_CROSS : NS_G) : EW_Y;
        PED_CROSS:  next_state = (time_count == 11)? PED_BLINK  : PED_CROSS;
        PED_BLINK:  next_state = (time_count == 13)? NS_G       : PED_BLINK;
        default:    next_state = NS_G;
    endcase
end

// Output control based on current state
always_comb begin: out_decoder
    r_light_ped = 0;
    case (state)
        NS_G: begin
            r_light_ns   = GREEN_LIGHT;
            r_light_ew   = RED_LIGHT;
            r_light_ped  = 0;
        end
        NS_Y: begin
            r_light_ns   = YELLOW_LIGHT;
            r_light_ew   = RED_LIGHT;
            r_light_ped  = 0;
        end
        EW_G: begin
            r_light_ns   = RED_LIGHT;
            r_light_ew   = GREEN_LIGHT;
            r_light_ped  = 0;
        end
        EW_Y: begin
            r_light_ns   = RED_LIGHT;
            r_light_ew   = YELLOW_LIGHT;
            r_light_ped  = 0;
        end
        PED_CROSS: begin
            r_light_ns   = RED_LIGHT;
            r_light_ew   = RED_LIGHT;
            r_light_ped  = 1;
        end
        PED_BLINK: begin
            r_light_ns   = RED_LIGHT;
            r_light_ew   = RED_LIGHT;
            r_light_ped  = ped_blink_toggle;
        end
        default: begin
            r_light_ns   = GREEN_LIGHT;
            r_light_ew   = RED_LIGHT;
            r_light_ped  = 0;
        end
    endcase
end

// Assign internal registers to output ports
assign o_light_ns   = r_light_ns;
assign o_light_ew   = r_light_ew;
assign o_light_ped  = r_light_ped;

endmodule