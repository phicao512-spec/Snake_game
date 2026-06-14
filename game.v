module game(clk, key, row, col);
input clk;
input [3:0] key; // 4 nut nhan tren kit

output [7:0] row;
output [7:0] col;

reg [3:0] key_meta = 4'hF;
reg [3:0] key_sync = 4'hF;
reg [3:0] movement_latched = 4'b0000;
wire [3:0] movement_raw;

assign movement_raw = ~key_sync;

// Dong bo input nut nhan va giu huong hop le gan nhat (one-hot)
always @(posedge clk)
begin
	key_meta <= key;
	key_sync <= key_meta;
	case (movement_raw)
	4'b0001,
	4'b0010,
	4'b0100,
	4'b1000:
		movement_latched <= movement_raw;
	default:
		movement_latched <= movement_latched;
	endcase
end

wire [3:0] movement;
assign movement = movement_latched;

// Bat dau game khi nhan bat ky nut naos
wire start;
assign start = |movement_raw;

wire [63:0] matrix;
wire [2:0] state;
wire [7:0] out;
wire fout;
wire [5:0] score;
wire [2:0] head_row, head_col;

freq_divider fd(clk, out, fout, score);
move snake_move(movement, head_row, head_col, clk, matrix, state, start, 1'b0, fout, score);
led_scanner led(clk, matrix, row, col, state);

endmodule