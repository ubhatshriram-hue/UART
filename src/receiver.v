
`timescale 1ns / 1ps

module u_rec (
    input            sys_rst,
    input            uart_clk,
    input            uart_rec_datah,
    output reg       rec_readyh,
    output reg       rec_busyh,
    output reg [7:0] rec_datah
);

    localparam IDLE = 2'd0;
    localparam WAIT = 2'd1;
    localparam REC  = 2'd2;
    localparam STOP = 2'd3;

    reg [1:0] f_syn;
    reg [3:0] count;
    reg [3:0] w_count;
    reg [2:0] ct, nt;
    reg [7:0] temp;

    always @(posedge uart_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            ct        <= IDLE;
            f_syn     <= 2'b00;
            temp      <= 8'd0;
            rec_datah <= 8'd0;
        end else begin
            ct       <= nt;
            f_syn[1] <= uart_rec_datah;
            f_syn[0] <= f_syn[1];
        end
    end

    always @(posedge uart_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            count <= 4'b0000;
        end else begin
            if ((ct == WAIT) || (ct == STOP))
                count <= count + 1'b1;
            else
                count <= 4'b0000;
        end
    end

    always @(*) begin
        nt         = ct;
        rec_busyh  = 1'b0;
        rec_readyh = 1'b0;
        rec_datah  = 8'd0;

        case (ct)

            IDLE: begin
                rec_busyh  = 1'b0;
                rec_readyh = 1'b1;
                if (!uart_rec_datah) begin
                    nt         = WAIT;
                    rec_busyh  = 1'b1;
                    rec_readyh = 1'b0;
                end else begin
                    nt      = IDLE;
                    w_count = 4'd10;
                end
            end

            WAIT: begin
                if (w_count == 4'd10) begin
                    if (count == 4'b0110)
                        nt = REC;
                    else
                        nt = WAIT;
                end else if (w_count == 4'd1) begin
                    if (count == 4'b1110)
                        nt = STOP;
                    else
                        nt = WAIT;
                end else begin
                    if (count == 4'b1110)
                        nt = REC;
                    else
                        nt = WAIT;
                end
            end

            REC: begin
                temp    = {f_syn[0], temp[7:1]};
                w_count = w_count - 1'b1;
                nt      = WAIT;
            end

            STOP: begin
                if (uart_rec_datah) begin
                    rec_datah  = temp;
                    rec_busyh  = 1'b0;
                    rec_readyh = 1'b1;
                end else begin
                    rec_datah  = 8'b0;
                    rec_busyh  = 1'b0;
                    rec_readyh = 1'b1;
                    nt         = IDLE;
                end
            end

            default: begin
                nt = IDLE;
            end

        endcase
    end

endmodule  
