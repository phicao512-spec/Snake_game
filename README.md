# 🐍 Snake Game trên FPGA — Cyclone IV EP4CE6E22C8

> **Đồ án thiết kế hệ thống số**: Lập trình game rắn săn mồi (Snake) trên kit FPGA Altera Cyclone IV, hiển thị trên ma trận LED 8×8, điều khiển bằng 4 nút nhấn.

![FPGA Board](fpga_board.jpg)

---

## 📑 Mục lục

1. [Giới thiệu](#-giới-thiệu)
2. [Lý thuyết nền tảng](#-lý-thuyết-nền-tảng)
3. [Danh sách linh kiện](#-danh-sách-linh-kiện)
4. [Sơ đồ kiến trúc hệ thống](#-sơ-đồ-kiến-trúc-hệ-thống)
5. [Mô tả các module Verilog](#-mô-tả-các-module-verilog)
6. [Nguyên lý hoạt động của thuật toán](#-nguyên-lý-hoạt-động-của-thuật-toán)
7. [Gán chân FPGA (Pin Assignment)](#-gán-chân-fpga-pin-assignment)
8. [Các bước thực hiện](#-các-bước-thực-hiện)
9. [Mô phỏng và kiểm thử](#-mô-phỏng-và-kiểm-thử)
10. [Xử lý sự cố](#-xử-lý-sự-cố)
11. [Kết quả](#-kết-quả)

---

## 🎯 Giới thiệu

Game **Snake (Rắn săn mồi)** là trò chơi kinh điển, trong đó người chơi điều khiển một con rắn di chuyển trên lưới để ăn táo. Mỗi lần ăn táo, rắn dài thêm một đốt và tốc độ tăng lên. Game kết thúc khi rắn cắn vào thân mình.

**Đặc điểm dự án:**
- Ngôn ngữ thiết kế: **Verilog HDL**
- Nền tảng phần cứng: **FPGA Altera Cyclone IV EP4CE6E22C8**
- Hiển thị: **Ma trận LED 8×8** (quét hàng multiplexing)
- Điều khiển: **4 nút nhấn** (Lên / Xuống / Trái / Phải)
- Công cụ tổng hợp: **Intel Quartus Prime Lite 21.1**
- Công cụ mô phỏng: **Icarus Verilog + GTKWave**

---

## 📖 Lý thuyết nền tảng

### 1. FPGA (Field-Programmable Gate Array)

FPGA là vi mạch logic khả trình, cho phép người dùng cấu hình lại phần cứng bên trong chip theo ý muốn. Khác với vi điều khiển (thực thi phần mềm tuần tự), FPGA thực thi logic **song song** ở mức cổng phần cứng, mang lại tốc độ xử lý rất cao.

| Đặc tính | Vi điều khiển | FPGA |
|---|---|---|
| Xử lý | Tuần tự (software) | Song song (hardware) |
| Ngôn ngữ | C/C++, Assembly | Verilog, VHDL |
| Tốc độ | Phụ thuộc tần số CPU | Phụ thuộc logic path |
| Tái cấu hình | Chỉ đổi phần mềm | Đổi toàn bộ phần cứng |

### 2. Ngôn ngữ mô tả phần cứng Verilog

Verilog HDL là ngôn ngữ mô tả phần cứng, dùng để thiết kế mạch số ở mức RTL (Register-Transfer Level). Các khối `always @(posedge clk)` mô tả các flip-flop hoạt động theo cạnh lên xung nhịp, cho phép tạo ra máy trạng thái (FSM) và logic tổ hợp.

### 3. Kỹ thuật quét LED ma trận (Multiplexing)

Ma trận LED 8×8 có 64 LED nhưng chỉ sử dụng 16 chân I/O (8 hàng + 8 cột). Nguyên lý hoạt động:

```
Thời gian →
────────────────────────────────────────────────
Chu kỳ 1: Bật hàng 0, xuất dữ liệu cột hàng 0
Chu kỳ 2: Bật hàng 1, xuất dữ liệu cột hàng 1
   ...
Chu kỳ 8: Bật hàng 7, xuất dữ liệu cột hàng 7
────────────────────────────────────────────────
(Lặp lại liên tục với tốc độ > 60Hz → mắt không nhận ra nhấp nháy)
```

Tại mỗi thời điểm chỉ **một hàng** được kích hoạt, dữ liệu cột tương ứng được xuất ra. Quét đủ nhanh (>60Hz), mắt người sẽ thấy toàn bộ hình ảnh liên tục.

### 4. Chống dội phím (Debounce) và đồng bộ tín hiệu

Nút nhấn cơ khí khi bấm/thả sẽ tạo ra nhiều xung nhiễu (bouncing). Dự án sử dụng **thanh ghi đồng bộ 2 tầng** (double flip-flop synchronizer) để lọc nhiễu và đồng bộ tín hiệu nút nhấn với miền xung nhịp của FPGA.

```
key (async) → [FF1: key_meta] → [FF2: key_sync] → logic xử lý
```

---

## 🧩 Danh sách linh kiện

### Phần cứng chính

| STT | Linh kiện | Số lượng | Mô tả |
|:---:|---|:---:|---|
| 1 | **Kit FPGA Cyclone IV EP4CE6E22C8** | 1 | Kit phát triển FPGA chính, xung nhịp 50MHz |
| 2 | **Module ma trận LED 8×8** (1 màu) | 1 | Hiển thị game, kiểu common-row |
| 3 | **Nút nhấn tích hợp trên kit** | 4 | KEY0–KEY3: điều khiển Lên/Xuống/Trái/Phải |
| 4 | **Cáp USB-Blaster** | 1 | Nạp bitstream từ máy tính xuống FPGA |
| 5 | **Dây cắm jumper (đực–cái)** | 16+ | Kết nối FPGA với module LED |
| 6 | **Nguồn cấp 5V/USB** | 1 | Cấp nguồn cho kit FPGA |

### Phần mềm

| STT | Phần mềm | Mục đích |
|:---:|---|---|
| 1 | **Intel Quartus Prime Lite 21.1** | Tổng hợp, gán chân, nạp FPGA |
| 2 | **Icarus Verilog** | Mô phỏng Verilog (miễn phí) |
| 3 | **GTKWave** | Hiển thị dạng sóng mô phỏng |

---

## 🏗 Sơ đồ kiến trúc hệ thống

### Sơ đồ khối tổng quan

```
┌──────────────────────────────────────────────────────────────────┐
│                         FPGA EP4CE6E22C8                        │
│                                                                  │
│   ┌──────────┐      ┌──────────────┐      ┌───────────────┐     │
│   │  4 Nút   │─────▶│  game.v      │      │ freq_divider  │     │
│   │  nhấn    │      │  (Top-level) │◄────▶│ (Chia tần số) │     │
│   │ KEY[3:0] │      │              │      │               │     │
│   └──────────┘      │ • Đồng bộ   │      │ • Game tick   │     │
│                     │   nút nhấn   │      │ • Tăng tốc    │     │
│                     │ • Chống đảo  │      │   theo điểm   │     │
│                     │   hướng      │      └───────────────┘     │
│                     └──────┬───────┘                             │
│                            │                                     │
│                            ▼                                     │
│                     ┌──────────────┐      ┌───────────────┐     │
│                     │   move.v     │─────▶│ led_scanner.v │     │
│                     │ (Logic game) │      │ (Quét LED)    │──┐  │
│                     │              │      │               │  │  │
│                     │ • Di chuyển  │      │ • Quét hàng   │  │  │
│                     │ • Ăn táo     │      │ • Active-low  │  │  │
│                     │ • Game over  │      │ • Chia tần    │  │  │
│                     │ • Wrap-around│      └───────────────┘  │  │
│                     └──────────────┘                          │  │
│                                                              │  │
└──────────────────────────────────────────────────────────────┼──┘
                                                               │
                                                               ▼
                                                     ┌──────────────┐
                                                     │  Ma trận LED │
                                                     │     8 × 8    │
                                                     │  row[7:0]    │
                                                     │  col[7:0]    │
                                                     └──────────────┘
```

### Sơ đồ luồng dữ liệu

```
 KEY[3:0]          movement[3:0]           matrix[63:0]          row[7:0]
(nút nhấn) ──▶ Đồng bộ + Latch ──▶ Logic di chuyển rắn ──▶ Quét LED ──▶ col[7:0]
                                          ▲                          (ma trận LED 8×8)
                                          │
                                     fout (game tick)
                                          │
                                   Bộ chia tần số
                                          │
                                     clk (50MHz)
```

---

## 📦 Mô tả các module Verilog

### 1. `game.v` — Module top-level

| Thuộc tính | Chi tiết |
|---|---|
| **Input** | `clk` (50MHz), `key[3:0]` (4 nút nhấn, active-low) |
| **Output** | `row[7:0]`, `col[7:0]` (điều khiển ma trận LED) |

**Chức năng:**
- Đồng bộ tín hiệu nút nhấn bằng 2 tầng flip-flop (`key_meta`, `key_sync`)
- Latch hướng di chuyển hợp lệ (chỉ chấp nhận 1 nút tại 1 thời điểm — mã one-hot)
- Tạo tín hiệu `start` khi bất kỳ nút nào được nhấn
- Kết nối 3 module con: `freq_divider`, `move`, `led_scanner`

### 2. `move.v` — Logic game chính

| Thuộc tính | Chi tiết |
|---|---|
| **Input** | `movement[3:0]`, `clk`, `fout`, `start`, `reset` |
| **Output** | `matrix[63:0]`, `state[2:0]`, `head_row[2:0]`, `head_col[2:0]`, `score[5:0]` |

**Chức năng:**
- Quản lý trạng thái game: **Màn hình chờ → Đang chơi → Game Over**
- Di chuyển rắn theo 4 hướng (UP/DOWN/LEFT/RIGHT)
- Xử lý **wrap-around** (xuyên tường): rắn đi ra biên này sẽ xuất hiện ở biên đối diện
- Phát hiện va chạm thân rắn → Game Over
- Sinh vị trí táo mới bằng công thức giả ngẫu nhiên
- Quản lý phần đuôi mở rộng khi ăn táo (lưu tối đa 30 đốt)
- Chống đảo hướng 180° (không cho rắn quay đầu đột ngột)
- Hiển thị **mặt cười** (màn hình chờ) và **mặt buồn** (game over) trên LED

### 3. `freq_divider.v` — Bộ chia tần số

| Thuộc tính | Chi tiết |
|---|---|
| **Input** | `clk` (50MHz), `score[5:0]` |
| **Output** | `fout` (game tick), `out[7:0]` |

**Chức năng:**
- Chia tần số clock 50MHz xuống tần số thấp tạo nhịp di chuyển cho rắn
- **Tăng tốc theo điểm số**: điểm càng cao, rắn di chuyển càng nhanh

| Thông số | Giá trị | Ý nghĩa |
|---|---|---|
| `BASE_HALF_PERIOD` | 25,000,000 | Nửa chu kỳ ban đầu (~1 bước/giây) |
| `SPEED_STEP` | 3,000,000 | Mỗi điểm giảm nửa chu kỳ đi 3M |
| `MIN_HALF_PERIOD` | 4,000,000 | Tốc độ tối đa (~6.25 bước/giây) |
| `MAX_SPEED_LEVEL` | 20 | Điểm > 20 không tăng tốc thêm |

**Công thức tính tốc độ:**

```
target_half_period = max(MIN_HALF_PERIOD, BASE_HALF_PERIOD - score × SPEED_STEP)
```

### 4. `led_scanner.v` — Bộ quét ma trận LED

| Thuộc tính | Chi tiết |
|---|---|
| **Input** | `clk`, `matrix[63:0]`, `state[2:0]` |
| **Output** | `row[7:0]`, `col[7:0]` |

**Chức năng:**
- Quét tuần tự 8 hàng của ma trận LED bằng bộ đếm `row_idx`
- Sử dụng **bộ chia tần quet** (`SCAN_DIV = 8192`) để giảm tốc độ quét, giúp hiển thị ổn định
- Hỗ trợ cấu hình **cực tính active-low/high** cho cả hàng và cột:
  - `ROW_ACTIVE_LOW`: hàng kích mức thấp
  - `COL_ACTIVE_LOW`: cột kích mức thấp

### 5. `game_tb.v` — Testbench mô phỏng

Testbench tự động kiểm tra 10 giai đoạn:

| Giai đoạn | Nội dung kiểm tra |
|:---:|---|
| 1 | Màn hình bắt đầu (hình trang trí) |
| 2 | Bắt đầu game khi nhấn nút |
| 3 | Rắn di chuyển sang phải (3 bước) |
| 4 | Đổi hướng — đi xuống |
| 5 | Đổi hướng — đi trái |
| 6 | Đổi hướng — đi lên |
| 7 | Kiểm tra chống đảo hướng 180° |
| 8 | Di chuyển liên tục đến khi Game Over |
| 9 | Hiển thị màn hình thua (mặt buồn) |
| 10 | Chơi lại game |

---

## 🧠 Nguyên lý hoạt động của thuật toán

### Máy trạng thái game (FSM)

```
                    ┌─────────────────┐
                    │   MÀN HÌNH CHỜ  │
                    │   (state_start  │
                    │      = 1)       │
                    │                 │
                    │  Hiển thị hình  │
                    │  trang trí      │
                    └────────┬────────┘
                             │ Nhấn bất kỳ nút
                             ▼
                    ┌─────────────────┐
            ┌──────▶│   ĐANG CHƠI     │◀──────┐
            │       │   (state_start  │       │
            │       │    = 0, over    │       │
            │       │    = 0)         │       │
            │       │                 │       │
            │       │  Rắn di chuyển  │       │
            │       │  Ăn táo, tăng   │       │
            │       │  điểm & tốc độ  │       │
            │       └────────┬────────┘       │
            │                │ Rắn cắn thân   │
            │                ▼                │
            │       ┌─────────────────┐       │
            │       │   GAME OVER     │       │
            │       │   (over = 1)    │       │
            │       │                 │       │
            │       │  Hiển thị mặt   │       │
            └───────│  buồn 😢        │───────┘
         Nhấn nút   │  Điểm = 0      │  Nhấn nút
         chơi lại   └─────────────────┘  chơi lại
```

### Thuật toán di chuyển rắn

Rắn được biểu diễn bằng một chuỗi tọa độ trên lưới 8×8:

```
Cấu trúc dữ liệu rắn:
┌──────┐  ┌────────┐  ┌──────┐  ┌──────────────────────────┐
│ head │→ │ center │→ │ tail │→ │ min[0], min[1], ..., min[score-1] │
│(3,3) │  │ (3,2)  │  │(3,1) │  │      (phần đuôi mở rộng)        │
└──────┘  └────────┘  └──────┘  └──────────────────────────┘
```

**Mỗi game tick (`posedge fout`):**

1. **Xác định hướng hợp lệ:**
   - Nếu người chơi nhấn hướng ngược 180° (ví dụ: đang đi LÊN nhấn XUỐNG) → **bỏ qua**, giữ hướng cũ
   - Ngược lại → cập nhật hướng mới

2. **Tính toán vị trí đầu mới:**
   ```
   UP:    next_head_row = (head_row == 0) ? 7 : head_row - 1
   DOWN:  next_head_row = (head_row == 7) ? 0 : head_row + 1
   LEFT:  next_head_col = (head_col == 0) ? 7 : head_col - 1
   RIGHT: next_head_col = (head_col == 7) ? 0 : head_col + 1
   ```
   → Rắn **xuyên tường** (wrap-around) thay vì chết khi chạm biên.

3. **Kiểm tra va chạm thân:**
   - So sánh vị trí đầu mới với `center`, `tail`, và tất cả `min[0..score-1]`
   - Nếu trùng → `over = 1` → Game Over

4. **Dịch chuyển thân rắn (nếu không va chạm):**
   ```
   min[j] ← min[j-1]    (với j = score-1 → 1)
   min[0] ← tail
   tail   ← center
   center ← head
   head   ← next_head
   ```
   → Mỗi đốt **kế thừa vị trí** của đốt phía trước, tạo hiệu ứng di chuyển.

5. **Ăn táo:**
   - Nếu `head == apple` → `score += 1`, sinh vị trí táo mới:
     ```
     apple_row = (123 × k) mod 7
     apple_col = (123 × (k+1)) mod 7
     k = k + 1
     ```

### Thuật toán sinh vị trí táo (Pseudo-random)

Dự án sử dụng **LCG đơn giản** (Linear Congruential Generator):
- Hằng số nhân: 123
- Biến đếm: `k` (tăng dần mỗi lần ăn táo)
- Phạm vi: 0–6 (lấy mod 7 để nằm trong lưới 8×8)

> **Lưu ý:** Đây là phương pháp giả ngẫu nhiên đơn giản, phù hợp cho game nhỏ. Trong thực tế có thể dùng LFSR (Linear Feedback Shift Register) để tạo số ngẫu nhiên chất lượng hơn.

### Cập nhật ma trận hiển thị

Mỗi chu kỳ clock, ma trận 64-bit `matrix[63:0]` được cập nhật:

```
matrix = 0 (xóa toàn bộ)

// Bật các pixel tại vị trí rắn
matrix[head_row × 8 + head_col] = 1
matrix[center_row × 8 + center_col] = 1
matrix[tail_row × 8 + tail_col] = 1
matrix[apple_row × 8 + apple_col] = 1

// Bật các đốt đuôi mở rộng
for (i = 0; i < score; i++)
    matrix[min_row[i] × 8 + min_col[i]] = 1
```

Ma trận này được `led_scanner` quét ra ma trận LED vật lý.

---

## 📌 Gán chân FPGA (Pin Assignment)

### Xung nhịp & Nút nhấn

| Tín hiệu | Chân FPGA | Chức năng | Ghi chú |
|---|:---:|---|---|
| `clk` | PIN_25 | Xung nhịp 50MHz | Thạch anh trên kit |
| `key[0]` | PIN_30 | Nút điều khiển 0 | Active-low, pull-up |
| `key[1]` | PIN_31 | Nút điều khiển 1 | Active-low, pull-up |
| `key[2]` | PIN_32 | Nút điều khiển 2 | Active-low, pull-up |
| `key[3]` | PIN_33 | Nút điều khiển 3 | Active-low, pull-up |

### Ma trận LED — Hàng (Row)

| Tín hiệu | Chân FPGA |
|---|:---:|
| `row[0]` | PIN_38 |
| `row[1]` | PIN_39 |
| `row[2]` | PIN_42 |
| `row[3]` | PIN_43 |
| `row[4]` | PIN_44 |
| `row[5]` | PIN_46 |
| `row[6]` | PIN_49 |
| `row[7]` | PIN_50 |

### Ma trận LED — Cột (Col)

| Tín hiệu | Chân FPGA |
|---|:---:|
| `col[0]` | PIN_110 |
| `col[1]` | PIN_111 |
| `col[2]` | PIN_112 |
| `col[3]` | PIN_113 |
| `col[4]` | PIN_115 |
| `col[5]` | PIN_119 |
| `col[6]` | PIN_120 |
| `col[7]` | PIN_121 |

> **I/O Standard:** 3.3V LVCMOS cho nút nhấn, 2.5V cho các chân còn lại.

---

## 🔧 Các bước thực hiện

### Bước 1: Chuẩn bị phần cứng

1. Chuẩn bị kit FPGA Cyclone IV EP4CE6E22C8
2. Chuẩn bị module ma trận LED 8×8
3. Kết nối dây theo bảng gán chân ở trên
4. Kết nối nguồn USB và cáp USB-Blaster

### Bước 2: Cài đặt phần mềm

1. Tải và cài đặt **Intel Quartus Prime Lite Edition** (miễn phí)
2. Cài đặt **Icarus Verilog** + **GTKWave** (tùy chọn, dùng cho mô phỏng)

### Bước 3: Mở project trong Quartus

1. Mở Quartus → **File** → **Open Project**
2. Chọn file `game.qpf` trong thư mục project
3. Kiểm tra 4 file Verilog đã được thêm:
   - `game.v` (top-level)
   - `move.v`
   - `freq_divide.v`
   - `led_scanner.v`

### Bước 4: Tổng hợp (Compilation)

1. Nhấn **Processing** → **Start Compilation** (hoặc `Ctrl+L`)
2. Chờ quá trình tổng hợp hoàn tất (không có lỗi)
3. Kiểm tra **Compilation Report** để xác nhận:
   - Không có Error
   - Resource usage trong giới hạn chip

### Bước 5: Gán chân I/O

> Nếu mở project từ file `.qsf` đã có sẵn, bước này đã được thực hiện tự động.

1. Vào **Assignments** → **Pin Planner**
2. Gán chân theo bảng ở mục [Gán chân FPGA](#-gán-chân-fpga-pin-assignment)
3. Compile lại sau khi gán chân

### Bước 6: Nạp chương trình lên FPGA

1. Kết nối USB-Blaster với máy tính và kit FPGA
2. Vào **Tools** → **Programmer**
3. Chọn file `.sof` trong thư mục `output_files/`
4. Nhấn **Start** để nạp
5. Nhấn bất kỳ nút nào trên kit để bắt đầu chơi!

### Bước 7: Chơi game! 🎮

| Nút | Chức năng |
|:---:|---|
| KEY0 | Di chuyển **LÊN** |
| KEY1 | Di chuyển **XUỐNG** |
| KEY2 | Di chuyển **TRÁI** |
| KEY3 | Di chuyển **PHẢI** |

---

## 🧪 Mô phỏng và kiểm thử

### Chạy mô phỏng bằng Icarus Verilog

**Yêu cầu:** Đã cài Icarus Verilog và GTKWave.

**Cách 1:** Chạy file batch có sẵn:
```bash
run_sim.bat
```

**Cách 2:** Chạy thủ công:
```bash
# Biên dịch
iverilog -o game_tb.vvp game_tb.v game.v move.v led_scanner.v freq_divide.v

# Chạy mô phỏng
vvp game_tb.vvp

# Xem dạng sóng
gtkwave game_tb.vcd
```

### Kết quả testbench

Testbench tự động kiểm tra:
- ✅ Hiển thị màn hình chờ
- ✅ Bắt đầu game khi nhấn nút
- ✅ Di chuyển 4 hướng (Lên/Xuống/Trái/Phải)
- ✅ Chống đảo hướng 180°
- ✅ Phát hiện Game Over khi va chạm thân
- ✅ Hiển thị mặt buồn khi thua
- ✅ Chơi lại game

Kết quả hiển thị dạng ma trận ASCII trong terminal:

```
  +---+---+---+---+---+---+---+---+
0 |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+
1 |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+
2 |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+
3 |   | # | # | # |   |   | # |   |  ← Rắn (3 đốt) + Táo
  +---+---+---+---+---+---+---+---+
  ...
    0   1   2   3   4   5   6   7
```

---

## 🔨 Xử lý sự cố

### LED chỉ sáng 1 hàng

**Nguyên nhân:** Cực tính active-low/high chưa đúng với module LED.

**Giải pháp:** Chỉnh 2 tham số trong `led_scanner.v`:

| Module LED | `ROW_ACTIVE_LOW` | `COL_ACTIVE_LOW` |
|---|:---:|:---:|
| Hàng active-high, cột active-low | `0` | `1` |
| Hàng active-low, cột active-high | `1` | `0` |
| Cả hai active-high | `0` | `0` |
| Cả hai active-low | `1` | `1` |

### Hình bị lật / ngược hàng

Trong `led_scanner.v`, đổi bit chọn hàng:
```verilog
// Thay thế:
row <= (8'b0000_0001 << row_idx);
// Bằng:
row <= (8'b1000_0000 >> row_idx);
```

### Rắn di chuyển quá nhanh trên board thật

Tăng giá trị `BASE_HALF_PERIOD` trong `freq_divide.v` (ví dụ: từ 25M lên 35M).

---

## 🏆 Kết quả

- Game Snake hoạt động hoàn chỉnh trên FPGA thật
- Hiển thị rắn, táo, và animation trên ma trận LED 8×8
- Điểm số tăng dần, tốc độ tăng theo điểm
- Rắn xuyên tường (wrap-around) thay vì chết khi chạm biên
- Game over khi rắn cắn thân, hiển thị mặt buồn
- Nhấn nút để chơi lại ngay lập tức
- Testbench đầy đủ, mô phỏng chạy chính xác

---

## 📂 Cấu trúc thư mục

```
Snake_game/
├── game.v                 # Module top-level
├── move.v                 # Logic game (di chuyển, ăn táo, game over)
├── freq_divide.v          # Bộ chia tần số (tốc độ game)
├── led_scanner.v          # Bộ quét ma trận LED 8×8
├── game_tb.v              # Testbench mô phỏng
├── game.qpf               # Quartus Project File
├── game.qsf               # Quartus Settings File (gán chân)
├── run_sim.bat             # Script chạy mô phỏng nhanh
├── FIX_LED_MATRIX.md       # Hướng dẫn sửa lỗi LED
├── fpga_board.jpg          # Hình ảnh kit FPGA
├── fpga_board_info.jpg     # Thông tin kit FPGA
├── ep4ce6_page.html        # Tài liệu tham khảo chip
├── Chain3.cdf              # Chain Description File
└── README.md               # File này
```

---

## 📝 Giấy phép

Dự án này được thực hiện cho mục đích học tập và nghiên cứu.

---

<p align="center">
  <b>🎮 Chúc bạn chơi vui vẻ! 🐍</b>
</p>
