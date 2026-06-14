module freq_divider(clk,out,fout,score);
input clk;
input [5:0]score;
output reg fout = 0;
output reg [7:0]out = 8'd0;

// 50MHz clock -> game tick cham hon de dieu khien muot tren board that.
localparam integer BASE_HALF_PERIOD = 32'd25_000_000; // ~1 move/s luc diem thap
localparam integer SPEED_STEP       = 32'd3_000_000;  // moi diem tang toc manh hon
localparam integer MIN_HALF_PERIOD  = 32'd4_000_000;  // gioi han toc do toi da (~6.25 move/s)
localparam [5:0]   MAX_SPEED_LEVEL  = 6'd20;          // diem cao hon nua van giu toc do toi da

reg [31:0]counter = 32'd0;
reg [31:0]target_half_period;
wire [5:0]speed_level;
wire [31:0]speed_decrease;
wire [31:0]max_reducible;

assign speed_level = (score > MAX_SPEED_LEVEL) ? MAX_SPEED_LEVEL : score;
assign speed_decrease = speed_level * SPEED_STEP;
assign max_reducible = BASE_HALF_PERIOD - MIN_HALF_PERIOD;

always @(*)
begin
	if (speed_decrease >= max_reducible)
		target_half_period = MIN_HALF_PERIOD;
	else
		target_half_period = BASE_HALF_PERIOD - speed_decrease;
end

always@(posedge clk)
begin
	if(counter >= (target_half_period - 1))
	begin
		counter <= 32'd0;
		fout <= !fout;
		out <= out + 8'd1;
	end
	else
		counter <= counter + 32'd1;
end
endmodule

