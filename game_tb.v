`timescale 1ns/1ps

module game_tb;

// =============================================
// KHAI BAO TIN HIEU
// =============================================
reg clk;
reg [3:0] key;          // nut nhan (active-low)
wire [7:0] row, col;    // dau ra ma tran LED

// Khoi tao module chinh
game uut (
    .clk(clk),
    .key(key),
    .row(row),
    .col(col)
);

// =============================================
// TRUY CAP TIN HIEU NOI BO DE QUAN SAT
// =============================================
wire [63:0] matrix      = uut.matrix;
wire [2:0]  head_r       = uut.head_row;
wire [2:0]  head_c       = uut.head_col;
wire [5:0]  score_val    = uut.score;
wire        fout_sig     = uut.fout;
wire        start_sig    = uut.start;
wire [3:0]  mov          = uut.movement;
wire        state_start  = uut.snake_move.state_start;
wire        over_flag    = uut.snake_move.over;
wire [2:0]  apple_r      = uut.snake_move.apple_row;
wire [2:0]  apple_c      = uut.snake_move.apple_col;
wire [2:0]  center_r     = uut.snake_move.center_row;
wire [2:0]  center_c     = uut.snake_move.center_col;
wire [2:0]  tail_r       = uut.snake_move.tail_row;
wire [2:0]  tail_c       = uut.snake_move.tail_col;

// Ma huong di chuyen
parameter UP = 4'd1, DOWN = 4'd2, LEFT = 4'd4, RIGHT = 4'd8;
parameter NO_KEY = 4'b1111; // tat ca nut tha (active-low)

// =============================================
// TAO XUNG NHIP CLK: chu ky 20ns (50MHz)
// =============================================
initial clk = 0;
always #10 clk = ~clk;

// Bien dem buoc di chuyen
integer step_count = 0;

// =============================================
// TASK: HIEN THI MA TRAN LED 8x8
// =============================================
task show_matrix;
    input [63:0] mat;
    integer r, c;
    begin
        $display("");
        $display("  +---+---+---+---+---+---+---+---+");
        for (r = 0; r < 8; r = r + 1) begin
            $write("%0d |", r);
            for (c = 0; c < 8; c = c + 1) begin
                if (mat[r*8+c])
                    $write(" # |");
                else
                    $write("   |");
            end
            $display("");
            $display("  +---+---+---+---+---+---+---+---+");
        end
        $display("    0   1   2   3   4   5   6   7");
    end
endtask

// =============================================
// TASK: HIEN THI TRANG THAI GAME
// =============================================
task show_status;
    begin
        $display("  Thoi gian     : %0t ns", $time);
        $display("  Dau ran       : hang=%0d, cot=%0d", head_r, head_c);
        $display("  Than giua     : hang=%0d, cot=%0d", center_r, center_c);
        $display("  Duoi ran      : hang=%0d, cot=%0d", tail_r, tail_c);
        $display("  Vi tri tao    : hang=%0d, cot=%0d", apple_r, apple_c);
        $display("  Diem so       : %0d", score_val);
        $display("  Trang thai    : state_start=%0b, over=%0b", state_start, over_flag);
        $display("  Huong hien tai: movement=%b (%s)", mov,
            (mov == UP)    ? "LEN" :
            (mov == DOWN)  ? "XUONG" :
            (mov == LEFT)  ? "TRAI" :
            (mov == RIGHT) ? "PHAI" : "KHONG");
    end
endtask

// =============================================
// TASK: HIEN THI DAY DU (MA TRAN + TRANG THAI)
// =============================================
task show_all;
    begin
        show_matrix(matrix);
        show_status;
        $display("=========================================");
    end
endtask

// =============================================
// TASK: NHAN NUT (active-low)
// movement_val: UP=1, DOWN=2, LEFT=4, RIGHT=8
// =============================================
task press_button;
    input [3:0] movement_val;
    begin
        key = ~movement_val; // dao vi nut active-low
    end
endtask

task release_button;
    begin
        key = NO_KEY; // tha tat ca nut
    end
endtask

// =============================================
// TASK: CHO N CANH LEN CUA FOUT (N buoc di)
// =============================================
task wait_n_moves;
    input integer n;
    integer i;
    begin
        for (i = 0; i < n; i = i + 1) begin
            @(posedge fout_sig);
            step_count = step_count + 1;
        end
        // Cho 2 clk de matrix cap nhat
        @(posedge clk);
        @(posedge clk);
        #1;
    end
endtask

// =============================================
// KICH BAN CHINH
// =============================================
initial begin
    // Luu waveform
    $dumpfile("game_tb.vcd");
    $dumpvars(0, game_tb);

    // Khoi tao: tha tat ca nut
    key = NO_KEY;
    step_count = 0;

    $display("");
    $display("=============================================");
    $display("  TESTBENCH - GAME RAN SAN MOI (SNAKE)");
    $display("  FPGA: Cyclone IV EP4CE6E22C8");
    $display("  Xung nhip: 50MHz (chu ky 20ns)");
    $display("=============================================");

    // -----------------------------------------
    // GIAI DOAN 1: MAN HINH BAT DAU
    // -----------------------------------------
    $display("");
    $display("=== [GIAI DOAN 1] MAN HINH BAT DAU ===");
    $display("  Hien thi hinh trang tri khi chua bat dau game");
    $display("  Cho tin hieu on dinh...");
    #2000; // cho cac thanh ghi khoi tao
    @(posedge clk); #1;
    show_all;

    // -----------------------------------------
    // GIAI DOAN 2: BAT DAU GAME (NHAN NUT PHAI)
    // -----------------------------------------
    $display("");
    $display("=== [GIAI DOAN 2] BAT DAU GAME ===");
    $display("  Nhan nut PHAI (KEY4) de bat dau choi");
    $display("  Ran bat dau tai vi tri (3,3), huong sang PHAI");
    press_button(RIGHT);
    wait_n_moves(1); // cho posedge fout → state_start = 0
    $display("  >> Game da bat dau!");
    show_all;
    release_button;

    // -----------------------------------------
    // GIAI DOAN 3: RAN DI PHAI (3 buoc)
    // -----------------------------------------
    $display("");
    $display("=== [GIAI DOAN 3] RAN DI SANG PHAI ===");
    $display("  Ran di chuyen sang phai 3 buoc");

    wait_n_moves(1);
    $display("  --- Buoc %0d ---", step_count);
    show_all;

    wait_n_moves(1);
    $display("  --- Buoc %0d ---", step_count);
    show_all;

    wait_n_moves(1);
    $display("  --- Buoc %0d ---", step_count);
    $display("  >> Kiem tra: Ran co an duoc tao khong?");
    show_all;

    // -----------------------------------------
    // GIAI DOAN 4: DOI HUONG - DI XUONG
    // -----------------------------------------
    $display("");
    $display("=== [GIAI DOAN 4] DOI HUONG - DI XUONG ===");
    $display("  Nhan nut XUONG (KEY2)");
    press_button(DOWN);
    #200; // giu nut 200ns
    release_button;

    wait_n_moves(1);
    $display("  --- Buoc %0d ---", step_count);
    show_all;

    wait_n_moves(1);
    $display("  --- Buoc %0d ---", step_count);
    show_all;

    // -----------------------------------------
    // GIAI DOAN 5: DOI HUONG - DI TRAI
    // -----------------------------------------
    $display("");
    $display("=== [GIAI DOAN 5] DOI HUONG - DI TRAI ===");
    $display("  Nhan nut TRAI (KEY3)");
    press_button(LEFT);
    #200;
    release_button;

    wait_n_moves(1);
    $display("  --- Buoc %0d ---", step_count);
    show_all;

    wait_n_moves(1);
    $display("  --- Buoc %0d ---", step_count);
    show_all;

    // -----------------------------------------
    // GIAI DOAN 6: DOI HUONG - DI LEN
    // -----------------------------------------
    $display("");
    $display("=== [GIAI DOAN 6] DOI HUONG - DI LEN ===");
    $display("  Nhan nut LEN (KEY1)");
    press_button(UP);
    #200;
    release_button;

    wait_n_moves(1);
    $display("  --- Buoc %0d ---", step_count);
    show_all;

    wait_n_moves(1);
    $display("  --- Buoc %0d ---", step_count);
    show_all;

    // -----------------------------------------
    // GIAI DOAN 7: KIEM TRA CHONG HUONG NGUOC
    // -----------------------------------------
    $display("");
    $display("=== [GIAI DOAN 7] KIEM TRA CHONG HUONG NGUOC ===");
    $display("  Ran dang di LEN → Nhan XUONG (huong nguoc)");
    $display("  Ran KHONG DUOC phep quay dau 180 do");
    press_button(DOWN); // co nhan XUONG khi dang di LEN
    #200;
    release_button;

    wait_n_moves(1);
    $display("  --- Buoc %0d ---", step_count);
    $display("  >> Kiem tra: Ran phai tiep tuc di LEN, khong doi huong");
    show_all;

    // -----------------------------------------
    // GIAI DOAN 8: DI DEN TUONG - GAME OVER
    // -----------------------------------------
    $display("");
    $display("=== [GIAI DOAN 8] DI DEN TUONG - GAME OVER ===");
    $display("  Ran di LEN lien tuc cho den khi cham tuong tren");
    press_button(UP);

    // Di len cho den khi game over hoac toi da 10 buoc
    repeat(10) begin
        wait_n_moves(1);
        $display("  --- Buoc %0d ---", step_count);
        show_all;
        if (over_flag == 1) begin
            $display("");
            $display("  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
            $display("  >>> GAME OVER! Ran cham tuong!");
            $display("  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        end
    end
    release_button;

    // -----------------------------------------
    // GIAI DOAN 9: MAN HINH THUA CUOC (MAT BUON)
    // -----------------------------------------
    $display("");
    $display("=== [GIAI DOAN 9] MAN HINH THUA CUOC ===");
    $display("  Hien thi mat buon tren ma tran LED");
    #500;
    @(posedge clk); #1;
    show_all;

    // -----------------------------------------
    // GIAI DOAN 10: CHOI LAI
    // -----------------------------------------
    $display("");
    $display("=== [GIAI DOAN 10] CHOI LAI ===");
    $display("  Nhan nut PHAI de bat dau lai game");
    press_button(RIGHT);
    wait_n_moves(2);
    $display("  >> Game da bat dau lai!");
    show_all;
    release_button;

    // Di mot vai buoc de xac nhan game chay binh thuong
    wait_n_moves(1);
    $display("  --- Di chuyen sau khi choi lai ---");
    show_all;

    wait_n_moves(1);
    show_all;

    // -----------------------------------------
    // KET THUC
    // -----------------------------------------
    $display("");
    $display("=============================================");
    $display("  TONG KET TESTBENCH");
    $display("=============================================");
    $display("  Tong so buoc da mo phong: %0d", step_count);
    $display("  Tat ca giai doan da hoan thanh!");
    $display("  Kiem tra file game_tb.vcd de xem waveform");
    $display("=============================================");
    $display("");

    #2000;
    $finish;
end

// =============================================
// TIMEOUT BAO VE (tranh treo vo han)
// =============================================
initial begin
    #5000000; // 5ms
    $display("");
    $display("!!! TIMEOUT - Mo phong qua 5ms, tu dong ket thuc !!!");
    $finish;
end

// =============================================
// THEO DOI SU KIEN QUAN TRONG
// =============================================
// Theo doi khi game bat dau
always @(negedge state_start) begin
    $display("  [SU KIEN] Game bat dau! (state_start: 1->0) tai T=%0t", $time);
end

// Theo doi khi game over
always @(posedge over_flag) begin
    $display("  [SU KIEN] Game Over! (over: 0->1) tai T=%0t", $time);
    $display("  [SU KIEN] Diem so cuoi: %0d", score_val);
end

// Theo doi khi diem thay doi
always @(score_val) begin
    if (score_val > 0)
        $display("  [SU KIEN] An tao! Diem so: %0d tai T=%0t", score_val, $time);
end

// Theo doi khi fout thay doi (buoc di chuyen)
always @(posedge fout_sig) begin
    if (state_start == 0 && over_flag == 0)
        $display("  [FOUT] Ran di chuyen - Dau tai (%0d,%0d) tai T=%0t",
                 head_r, head_c, $time);
end

endmodule
