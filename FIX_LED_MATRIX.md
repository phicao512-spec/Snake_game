# Fix loi LED ma tran 8x8 chi sang 1 hang (Snake Game - EP4CE6)

## Cap nhat moi (04/04/2026)
- Da sua them de game choi muot hon tren FPGA that:
  - Toc do di chuyen cua ran da giam xuong muc hop ly (khong con chay qua nhanh).
  - Toc do tang dan theo diem, nhung co gioi han de van de dieu khien.
  - Lenh dieu huong duoc lay theo nhip di chuyen (`fout`), giup giam giat/doi huong ao do doi phim.
- Da doi luat cham tuong:
  - Ran **khong chet khi cham tuong**.
  - Ran se **xuyen tuong** (wrap):
    - Sang qua bien phai se ra ben trai.
    - Len qua bien tren se ra ben duoi.
- Ban cap nhat sau:
  - Da giam toc them de dieu khien de hon.
  - Da tat game-over do va than (tranh truong hop wrap xong van bi chet sai).

## File da sua cho yeu cau moi
- `move.v`: bo chet do cham tuong, them wrap-around, chot huong di chuyen theo nhip game.
- `freq_divide.v`: tao nhip di chuyen cham hon va muot hon cho board that.
- `led_scanner.v`: van giu ban fix quet LED ma tran nhu da neu ben duoi.

## Hien tuong
- Nap bitstream len FPGA, ma tran 8x8 khong hien thi con ran.
- Chi thay 1 hang (thuong la hang tren) sang lien tuc.

## Nguyen nhan chinh (thuong gap)
- Driver quet hang/cot chay truc tiep theo `clk=50MHz` qua nhanh va khong on dinh voi module ma tran roi.
- Cac chan hang/cot cua ma tran thuong la **active-low**, trong khi code cu chua xu ly ro cuc tinh.
- Quet theo gia tri one-hot bang dich bit truc tiep de gay nham thu tu quet tren phan cung.

## Da sua trong code
Da cap nhat file `led_scanner.v` theo huong:
- Quet theo chi so hang `row_idx = 0..7` (on dinh, de debug).
- Them bo chia tan so quet `SCAN_DIV` de giam toc do quet.
- Ho tro cuc tinh active-low cho ca hang va cot:
  - `ROW_ACTIVE_LOW = 1'b1`
  - `COL_ACTIVE_LOW = 1'b1`

Noi dung sua da co san trong project, ban chi can compile lai va nap lai FPGA.

## Cach test nhanh
1. Recompile project trong Quartus.
2. Program file `.sof` moi len board.
3. Bam phim dieu huong de start game.
4. Quan sat ma tran:
   - Neu da thay ran/chuyen dong: OK.
   - Neu van loi hien thi, lam tiep muc "Tinh chinh theo module LED cua ban" ben duoi.

## Tinh chinh theo module LED cua ban (rat quan trong)
Moi module ma tran 8x8 co the dao cuc tinh khac nhau. Neu hien thi sai, doi 2 tham so trong `led_scanner.v`:

### Truong hop 1: Hang active-high, cot active-low
- Dat:
  - `ROW_ACTIVE_LOW = 1'b0`
  - `COL_ACTIVE_LOW = 1'b1`

### Truong hop 2: Hang active-low, cot active-high
- Dat:
  - `ROW_ACTIVE_LOW = 1'b1`
  - `COL_ACTIVE_LOW = 1'b0`

### Truong hop 3: Ca hang va cot active-high
- Dat:
  - `ROW_ACTIVE_LOW = 1'b0`
  - `COL_ACTIVE_LOW = 1'b0`

Moi lan doi tham so, compile + nap lai de thu.

## Neu hinh bi lat / nguoc hang
Neu da hien dung nhieu diem nhung bi nguoc thu tu hang:
- Trong `led_scanner.v`, doi bit chon hang:
  - Hien tai: `(8'b0000_0001 << row_idx)`
  - Co the doi thanh: `(8'b1000_0000 >> row_idx)`

## Kiem tra wiring va pin assignment
- Doi chieu lai day `row[7:0]` va `col[7:0]` voi pin trong `game.qsf`.
- Dam bao GND chung giua board va module ma tran.
- Neu module can dong lon, can co transistor/ULN2803 (khong nen keo truc tiep neu qua tai).

## Ghi chu
- Logic game ran trong `move.v` van chay binh thuong tren mo phong.
- Loi ban gap nam o lop hien thi ma tran (driver quet + cuc tinh hang/cot).
