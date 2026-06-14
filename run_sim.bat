@echo off
color 0A
echo ===============================================
echo   CHAY MO PHONG BANG ICARUS VERILOG
echo ===============================================
echo.
echo [1/3] Dang bien dich cac file Verilog...
iverilog -o game_tb.vvp game_tb.v game.v move.v led_scanner.v freq_divide.v
if errorlevel 1 (
    echo.
    echo [LOI] Bien dich that bai! Kiem tra lai code cua ban.
    pause
    exit /b
)

echo [2/3] Bien dich xong! Dang chay Testbench...
echo.
vvp game_tb.vvp

echo.
echo [3/3] Mo phong hoan tat! Dang mo GTKWave de xem song...
gtkwave game_tb.vcd

echo.
echo Hoan thanh! Nhan phim bat ky de thoat...
pause >nul
