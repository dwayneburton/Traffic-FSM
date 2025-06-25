/***************************************************/
/* Traffic Light Controller Testbench              */
/* Verifies FSM-based traffic light sequencing     */
/***************************************************/

`timescale 1ns/1ps

module traffic_tb ();

// Clock and simulation timing parameters
localparam CYCLES_PER_SEC = 16;   // Reduced cycles/sec for faster simulation
localparam CLK_PERIOD = 2;        // 2 ns clock period

// Time-based traffic FSM configuration
localparam bit [63:0] CYCLES_PER_TRAFFIC_CYCLE = 10 * CYCLES_PER_SEC;
localparam bit [63:0] CYCLES_PER_PEDESTRIAN_CROSSING = 4 * CYCLES_PER_SEC;

// DUT interface signals
logic clk;
logic i_maintenance;
logic [3:0] i_ped_buttons;
logic [2:0] o_light_ns;
logic [2:0] o_light_ew;
logic o_light_ped;
logic sim_failed;

// Instantiate DUT
traffic #(
    .CYCLES_PER_SEC(CYCLES_PER_SEC)
) dut (
    .clk(clk),
    .i_maintenance(i_maintenance),
    .i_ped_buttons(i_ped_buttons),
    .o_light_ns(o_light_ns),
    .o_light_ew(o_light_ew),
    .o_light_ped(o_light_ped)
);

// Clock generation
initial begin
    clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Local test control
logic test;

initial begin
    sim_failed     = 1'b0;
    i_maintenance  = 1'b1;
    i_ped_buttons  = 4'b0000;
    #(5 * CLK_PERIOD);

    // Release reset and begin testing
    #(CLK_PERIOD/2);
    i_maintenance = 1'b0;
    test = 1'b0;

    // Test sequence

    // NS Green
    test = ~test;
    for (int i = 0; i < CYCLES_PER_SEC * 3; i++) begin
        if (o_light_ns != 3'b010 || o_light_ew != 3'b100 || o_light_ped != 0) begin
            $display("FAILED at cycle %d: NS Green!", i);
            sim_failed = 1'b1;
        end
        #(CLK_PERIOD);
    end

    // NS Yellow
    test = ~test;
    for (int i = 0; i < CYCLES_PER_SEC * 2; i++) begin
        if (o_light_ns != 3'b110 || o_light_ew != 3'b100 || o_light_ped != 0) begin
            $display("FAILED at cycle %d: NS Yellow!", i);
            sim_failed = 1'b1;
        end
        #(CLK_PERIOD);
    end

    // Maintenance reset
    test = ~test;
    i_maintenance = 1'b1;
    #(CLK_PERIOD);
    for (int i = 0; i < CYCLES_PER_SEC; i++) begin
        if (o_light_ns != 3'b010 || o_light_ew != 3'b100 || o_light_ped != 0) begin
            $display("FAILED at cycle %d: Maintenance NS Green!", i);
            sim_failed = 1'b1;
        end
        #(CLK_PERIOD);
    end
    i_maintenance = 1'b0;

    // Repeat NS Green / Yellow again

    // Pedestrian button press
    i_ped_buttons = 1;

    // EW Green
    test = ~test;
    for (int i = 0; i < CYCLES_PER_SEC * 3; i++) begin
        if (o_light_ns != 3'b100 || o_light_ew != 3'b010 || o_light_ped != 0) begin
            $display("FAILED at cycle %d: EW Green!", i);
            sim_failed = 1'b1;
        end
        #(CLK_PERIOD);
    end

    // Pedestrian crossing ON
    i_ped_buttons = 0;
    test = ~test;
    for (int i = 0; i < CYCLES_PER_SEC * 2; i++) begin
        i_ped_buttons = 1;
        if (o_light_ns != 3'b100 || o_light_ew != 3'b100 || o_light_ped != 1) begin
            $display("FAILED at cycle %d: PED ON!", i);
            sim_failed = 1'b1;
        end
        #(CLK_PERIOD);
    end
    i_ped_buttons = 0;

    // Pedestrian blinking
    test = ~test;
    for (int i = 0; i < 4; i++) begin
        for (int j = 0; j < (CYCLES_PER_SEC / 4); j++) begin
            if (o_light_ns != 3'b100 || o_light_ew != 3'b100 || o_light_ped != 0) begin
                $display("FAILED: PED Blink OFF!");
                sim_failed = 1'b1;
            end
            #(CLK_PERIOD);
        end
        for (int j = 0; j < (CYCLES_PER_SEC / 4); j++) begin
            if (o_light_ns != 3'b100 || o_light_ew != 3'b100 || o_light_ped != 1) begin
                $display("FAILED: PED Blink ON!");
                sim_failed = 1'b1;
            end
            #(CLK_PERIOD);
        end
    end

    // Final pass/fail result
    if (sim_failed)
        $display("TEST FAILED!");
    else
        $display("TEST PASSED!");

    $stop;
end

endmodule