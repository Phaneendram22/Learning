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

@echo off
setlocal EnableDelayedExpansion

REM Wait for networking to come up
timeout /t 30 /nobreak >nul

REM Find first connected interface (robust)
for /f "tokens=1,* delims=:" %%A in ('
  netsh interface show interface ^| findstr /R /C:"Connected"
') do (
  for %%I in (%%B) do set IFACE=%%I
)

REM If still empty, fallback to Ethernet
if "%IFACE%"=="" set IFACE=Ethernet

echo Using interface: %IFACE%

REM Assign static IP
netsh interface ipv4 set address name="%IFACE%" static 192.168.1.100 255.255.255.0 192.168.1.1

REM Set DNS
netsh interface ipv4 set dns name="%IFACE%" static 8.8.8.8
netsh interface ipv4 add dns name="%IFACE%" 8.8.4.4 index=2

REM Remove scheduled task so it runs once
schtasks /delete /tn FirstBoot-Net /f

exit /b 0


#################################################################################################################################################################################################



@echo off
netsh interface ip set address name="Ethernet Instance 0" static 32.123.205.165 255.255.255.224 32.123.205.161
netsh interface ip add dns name="Ethernet Instance 0" addr=135.21.13.15 index=1
wmic computersystem where name="%computername%" call rename "rd2wa601wtds01"
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
powershell -ExecutionPolicy Bypass -File C:\init_disks.ps1
shutdown /r /t 0
del "%~f0"



###############################################################################################################################################



@echo off
setlocal EnableDelayedExpansion

REM Wait for network stack
timeout /t 20 /nobreak

REM Detect connected interface (Ethernet Instance X)
for /f "skip=3 tokens=3*" %%A in ('netsh interface show interface ^| findstr /R /C:"Connected"') do (
    set IFACE=%%A
)

REM Safety check
if "%IFACE%"=="" (
    echo ERROR: No connected network interface found
    exit /b 1
)

echo Using interface: "%IFACE%"

REM Set IP and DNS
netsh interface ip set address name="%IFACE%" static 32.123.205.165 255.255.255.224 32.123.205.161
netsh interface ip add dns name="%IFACE%" addr=135.21.13.15 index=1

REM Rename host
wmic computersystem where name="%computername%" call rename "rd2wa601wtds01"

REM Enable firewall rule
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

REM Initialize disks
powershell -ExecutionPolicy Bypass -File C:\init_disks.ps1

REM Reboot
shutdown /r /t 0

REM Delete script after execution
del "%~f0"



##############################################################################################################################################



@echo off
setlocal EnableDelayedExpansion

for /f "tokens=*" %%I in ('netsh interface show interface ^| findstr /I "Ethernet Instance"') do (
    set IFACE=%%I
    goto :FOUND
)

:FOUND
if "%IFACE%"=="" (
    echo ERROR: Ethernet Instance interface not found
    exit /b 1
)

REM Extract interface name (last column)
for %%A in (%IFACE%) do set IFACE_NAME=%%A

REM Apply settings
netsh interface ip set address name="%IFACE_NAME%" static 32.123.205.165 255.255.255.224 32.123.205.161
netsh interface ip add dns name="%IFACE_NAME%" addr=135.21.13.15 index=1

wmic computersystem where name="%computername%" call rename "rd2wa601wtds01"
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
powershell -ExecutionPolicy Bypass -File C:\init_disks.ps1
shutdown /r /t 0
del "%~f0"

##############################################################################################################################################


@echo off
setlocal EnableDelayedExpansion

for /f "skip=3 tokens=4,*" %%A in ('netsh interface show interface ^| findstr /I "Ethernet Instance"') do (
    set IFACE_NAME=%%A %%B
    goto :FOUND
)

:FOUND
if "%IFACE_NAME%"=="" (
    echo ERROR: Interface not found
    exit /b 1
)

netsh interface ip set address name="%IFACE_NAME%" static 32.123.205.165 255.255.255.224 32.123.205.161
netsh interface ip add dns name="%IFACE_NAME%" addr=135.21.13.15 index=1

wmic computersystem where name="%computername%" call rename "rd2wa601wtds01"
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
powershell -ExecutionPolicy Bypass -File C:\init_disks.ps1
shutdown /r /t 0
del "%~f0"
