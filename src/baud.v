

module u_baud
#(
    parameter SYS_CLK_FREQ = 50000000,
    parameter BAUD_RATE    = 9600
)
(
    input  wire sys_clk,
    input  wire sys_rst,

    output reg baud_clk
);

    reg [15:0] count;

    always @(posedge sys_clk or negedge sys_rst)
    begin
        if (!sys_rst)
        begin
            count    <= 0;
            baud_clk <= 0;
        end
        else
        begin

            if (count == (SYS_CLK_FREQ / (BAUD_RATE * 16 * 2)) - 1)
            begin
                count <= 0;
                baud_clk <= ~baud_clk;
            end
            else
            begin
                count <= count + 1;
            end

        end
    end

endmodule

