chcp 936 & cls & @echo off & color A & cd "%~dp0" &TITLE cloudflareIP测速
setlocal enabledelayedexpansion
TITLE 获取cloudflare IP
curl https://anycast.freecdn.workers.dev -o ip1.txt -#
set numN=%random%
set /a numN=numN%%50+50
findstr "%numN%" ip1.txt > ip.txt
Call :取前50个 ip.txt
cls
echo =========================================================
TITLE 包含%numN% 随机IP测速中…………
echo 包含%numN% 随机IP测速中…………
echo =========================================================
if EXIST "%~dp0temp" rd /s /q "%~dp0temp"
mkdir temp
echo WScript.sleep 500 > sleep.vbs
for /f "tokens=1,2" %%a in ('type "ip.txt"') do (
sleep.vbs
start /b curl --resolve speed.cloudflare.com:443:%%a https://speed.cloudflare.com/__down?bytes=1000000000 -o temp/%%a -s --connect-timeout 2 --max-time 10
echo %%a 启动测速
)
echo =========================================================
TITLE 等待包含%numN% 随机IP 测速进程结束,…………大约需要15秒
echo 等待包含%numN% 随机IP 测速进程结束,…………大约需要15秒
echo =========================================================
choice /t 15 /d y /n >nul
cls
echo =========================================================
TITLE 包含%numN% 随机IP测速排序结果（请选择排最前面的IP!）
echo 包含%numN% 随机IP测速排序结果（请选择排最前面的IP!）
echo ---------------------------------------------------------
echo 时间			单位时间下载字节	IP
echo ---------------------------------------------------------
dir /o:-s temp > ip1.txt
findstr "%numN%" ip1.txt > ip.txt
type ip.txt
echo ---------------------------------------------------------
echo 请选择排最前面的IP!
echo =========================================================
rd /s /q "%~dp0temp"
del ip.txt ip1.txt sleep.vbs ip.txt_tmp.txt
pause&goto :eof

:取前50个
sort %1>%1_tmp.txt
echo.>%1
set count=0
for /f "tokens=1,2" %%a in (%1_tmp.txt) do (
echo %%a >> %1
set /a count+=1
if !count! equ 50 goto :eof
)
del %1_tmp.txt >nul
goto :eof

pause&goto :eof
