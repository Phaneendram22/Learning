@echo off

timeout /t 20 /nobreak

for /f "skip=3 tokens=3*" %%A in ('netsh interface show interface ^| find "Connected"') do (
  set IFACE=%%A
)

netsh interface ip set address name="%IFACE%" static 192.168.1.100 255.255.255.0 192.168.1.1
netsh interface ip set dns name="%IFACE%" source=none
netsh interface ip add dns name="%IFACE%" 8.8.8.8 index=1

exit /b 0




@echo off
setlocal EnableDelayedExpansion

REM Wait for network stack
timeout /t 20 /nobreak

REM Detect active interface
for /f "skip=3 tokens=3*" %%A in ('netsh interface show interface ^| find "Connected"') do (
  set IFACE=%%A
)

REM Debug (optional)
echo Using interface: !IFACE!

REM Set IP address
netsh interface ip set address name="!IFACE!" static 192.168.1.100 255.255.255.0 192.168.1.1

REM Clear existing DNS
netsh interface ip set dns name="!IFACE!" source=none

REM Add DNS servers
netsh interface ip add dns name="!IFACE!" addr=8.8.8.8 index=1
netsh interface ip add dns name="!IFACE!" addr=8.8.4.4 index=2

REM Remove scheduled task (one-time execution)
schtasks /delete /tn FirstBoot-Net /f

exit /b 0

