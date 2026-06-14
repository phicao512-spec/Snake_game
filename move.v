module move(movement,head_row,head_col,clk,matrix,state,start,reset,fout,score);
input [3:0]movement;
input clk,fout;
input start,reset;
reg [2:0]apple_row=3;
reg [2:0]apple_col=6;
output reg [2:0]state=0;
reg [2:0]next_state;
reg [3:0]old_movement=0;
reg [3:0]dir_use=0;
reg [2:0]next_head_row=3;
reg [2:0]next_head_col=3;
reg hit_body=0;
reg over=0;
reg state_start=1;
output reg [63:0] matrix=0;

output reg [2:0]head_row=3,head_col=3;
reg [2:0]center_row=3,center_col=2;
reg [2:0]tail_row=3,tail_col=1;

reg [2:0]min_row[30:0]; // duoi that cua ran
reg [2:0]min_col[30:0]; // do dai toi da la 30, vi diem so kho vuot qua 30
output reg [5:0]score=0; 

parameter UP = 1, DOWN = 2, LEFT = 4, RIGHT = 8;
integer k=234;// dung de tao so ngau nhien
integer i=0;// bien dem vong lap
integer j=0;// bien dem vong lap
integer m=0;// bien dem vong lap
always@(posedge clk)
begin
	if (state_start == 1)
	begin
		matrix[7:0]  =8'b00000000; 
		matrix[15:8] =8'b00000000; 
		matrix[23:16]=8'b00000010; 
		matrix[31:24]=8'b01001100; 
		matrix[39:32]=8'b10101100; 
		matrix[47:40]=8'b10010000; 
		matrix[55:48]=8'b01000000; 
		matrix[63:56]=8'b00100000; 
	end
	else if(over == 1) // thua cuoc, hien thi mat buon
	begin
		score = 0;
		matrix[7:0]  =8'b00000000; 
		matrix[15:8] =8'b01100110; 
		matrix[23:16]=8'b01100110; 
		matrix[31:24]=8'b00000000; 
		matrix[39:32]=8'b00011000; 
		matrix[47:40]=8'b00100100; 
		matrix[55:48]=8'b01000010; 
		matrix[63:56]=8'b00000000; 
		
		//matrix =0; // xoa ma tran
	end
	else
	begin
		matrix=0; // xoa ma tran
        matrix[head_row*8+head_col]=1;
        matrix[center_row*8+center_col]=1;
        matrix[tail_row*8+tail_col]=1;
		matrix[apple_row*8+apple_col] =  1;

		// hien thi phan duoi that cua ran
		if(score>0)
		begin
			for(i=0; i < 30; i=i+1) // do dai toi da la 30
			begin
				if(i < score)
					matrix[min_row[i]*8+min_col[i]]=1;
			end	
		end	
		// khi an tao	
		if((head_row == apple_row)&&(head_col == apple_col))
		begin
		// 	tao qua tao moi
			apple_row <= (123*k)%7;
			apple_col <= (123*(k+1))%7;
	//		matrix[apple_row*8+apple_col] =  1;
			k = k + 1;
			score <= score+1;
		end
		else
		begin
		//	matrix[apple_row*8+apple_col] = 1;
			apple_row <= apple_row;
			apple_col <= apple_col;
		end
	end
end

always@(posedge fout)
begin
		if (state_start == 1)
		begin
			if(start == 1)
			begin
				state_start = 0;
				if ((movement == UP) || (movement == DOWN) || (movement == RIGHT))
					old_movement <= movement;
				else
					old_movement <= RIGHT;
				head_row <= 3;
				head_col <= 3;
                center_row <= 3;
                center_col <= 2;
                tail_row <= 3;
                tail_col <= 1;
				min_row[0] <= 3;
				min_col[0] <= 0;
			end
			else
			begin
				state_start = 1;
			end
		end
		else if(over == 1) // ket thuc game 
		begin
			if(start == 1) // cho tin hieu bat dau
			begin
				over <= 0;
					if ((movement == UP) || (movement == DOWN) || (movement == RIGHT))
						old_movement <= movement;
					else
						old_movement <= RIGHT;
				head_row <= 3;
				head_col <= 3;
                center_row <= 3;
                center_col <= 2;
                tail_row <= 3;
                tail_col <= 1;
				min_row[0] <= 3;
				min_col[0] <= 0;
			end
			else
			begin
				over <= 1;
			end
		end
		else
		begin
			dir_use = old_movement;
			if (movement != 0)
			begin
				if((old_movement == UP && movement == DOWN) ||
				   (old_movement == DOWN && movement == UP) ||
				   (old_movement == LEFT && movement == RIGHT) ||
				   (old_movement == RIGHT && movement == LEFT))
					dir_use = old_movement;
				else
					dir_use = movement;
			end
			old_movement <= dir_use;

			next_head_row = head_row;
			next_head_col = head_col;
			case(dir_use)
			UP: // di len
			begin
				next_head_row = (head_row == 0) ? 3'd7 : (head_row - 3'd1);
			end
			DOWN:// di xuong
			begin
				next_head_row = (head_row == 3'd7) ? 3'd0 : (head_row + 3'd1);
			end    
			LEFT:  // di trai 
			begin
				next_head_col = (head_col == 0) ? 3'd7 : (head_col - 3'd1);
			end		
			RIGHT: // di phai
			begin
				next_head_col = (head_col == 3'd7) ? 3'd0 : (head_col + 3'd1);
			end
			default: 
			begin
				next_head_row = head_row;
				next_head_col = head_col;
			end
			endcase

			hit_body = 0;
			if ((next_head_row == center_row && next_head_col == center_col) ||
			    (next_head_row == tail_row && next_head_col == tail_col))
				hit_body = 1;

			for (m=0; m<30; m=m+1)
			begin
				if ((m < score) && (next_head_row == min_row[m]) && (next_head_col == min_col[m]))
					hit_body = 1;
			end

			if (hit_body)
			begin
				over <= 1;
			end
			else
			begin
				over <= 0;
				head_row <= next_head_row;
				head_col <= next_head_col;
				center_row <= head_row;
				center_col <= head_col;
				tail_row <= center_row;
				tail_col <= center_col;
				min_row[0] <= tail_row;
				min_col[0] <= tail_col;
				for (j=1; j<30; j=j+1)
				begin
					if (j < score)
					begin
						min_row[j] <= min_row[j-1];
						min_col[j] <= min_col[j-1];
					end
				end
			end
			
		end
end

endmodule
