module led_scanner(clk,matrix,row,col,state);
input clk;
input [63:0]matrix; // ma tran 64 bit (8x8 LED)
output reg [7:0]row = 8'b0000_0001;
output reg [7:0]col = 8'b1111_1111;
input [2:0]state;

// Thong thuong module ma tran roi dung kieu kich muc thap.
localparam ROW_ACTIVE_LOW = 1'b0;
localparam COL_ACTIVE_LOW = 1'b1;

// Giam toc do quet de hien thi on dinh hon tren phan cung that.
localparam integer SCAN_DIV = 14'd8192;

reg [13:0] scan_cnt = 14'd0;
reg [2:0] row_idx = 3'd0;
reg [7:0] row_pixels;

always @(posedge clk) begin
    if (scan_cnt == (SCAN_DIV - 1)) begin
        scan_cnt <= 14'd0;
        row_idx <= row_idx + 3'd1;
    end else begin
        scan_cnt <= scan_cnt + 14'd1;
    end

    case (row_idx)
        3'd0: row_pixels <= matrix[7:0];
        3'd1: row_pixels <= matrix[15:8];
        3'd2: row_pixels <= matrix[23:16];
        3'd3: row_pixels <= matrix[31:24];
        3'd4: row_pixels <= matrix[39:32];
        3'd5: row_pixels <= matrix[47:40];
        3'd6: row_pixels <= matrix[55:48];
        default: row_pixels <= matrix[63:56];
    endcase

    if (ROW_ACTIVE_LOW)
        row <= ~(8'b0000_0001 << row_idx);
    else
        row <= (8'b0000_0001 << row_idx);

    if (COL_ACTIVE_LOW)
        col <= ~row_pixels;
    else
        col <= row_pixels;
end
endmodule
