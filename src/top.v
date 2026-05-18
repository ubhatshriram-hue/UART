
`timescale 1ns / 1ps

module top #(
    parameter SYS_CLK_FREQ = 50000000,
    parameter BAUD_RATE    = 9600,
    parameter WIDTH        = 8
)(
    input              sys_clk,
    input              sys_rst,
    input              xmitH,
    input  [WIDTH-1:0] xmit_dataH,
    input              uart_rec_datah,
    output             uart_XMIT_dataH,
    output             xmit_doneH,
    output             xmit_active,
    output             rec_readyh,
    output             rec_busyh,
    output [7:0]       rec_datah
);

    wire baud_clk;

    u_baud #(
        .SYS_CLK_FREQ (SYS_CLK_FREQ),
        .BAUD_RATE    (BAUD_RATE)
    ) baud_gen (
        .sys_clk  (sys_clk),
        .sys_rst  (sys_rst),
        .baud_clk (baud_clk)
    );

    transmitter #(
        .WIDTH (WIDTH)
    ) uart_tx (
        .sys_rst         (sys_rst),
        .uart_clk        (baud_clk),
        .xmitH           (xmitH),
        .xmit_dataH      (xmit_dataH),
        .uart_XMIT_dataH (uart_XMIT_dataH),
        .xmit_doneH      (xmit_doneH),
        .xmit_active     (xmit_active)
    );

    u_rec uart_rx (
        .sys_rst         (sys_rst),
        .uart_clk        (baud_clk),
        .uart_rec_datah  (uart_rec_datah),
        .rec_readyh      (rec_readyh),
        .rec_busyh       (rec_busyh),
        .rec_datah       (rec_datah)
    );

endmodule
