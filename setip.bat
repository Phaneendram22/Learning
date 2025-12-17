@echo off

timeout /t 20 /nobreak

for /f "skip=3 tokens=3*" %%A in ('netsh interface show interface ^| find "Connected"') do (
  set IFACE=%%A
)

netsh interface ip set address name="%IFACE%" static 192.168.1.100 255.255.255.0 192.168.1.1
netsh interface ip set dns name="%IFACE%" source=none
netsh interface ip add dns name="%IFACE%" 8.8.8.8 index=1

exit /b 0
