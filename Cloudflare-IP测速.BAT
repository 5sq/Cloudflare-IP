chcp 936 & cls & @echo off & color A & cd "%~dp0" &TITLE cloudflareIP测速
setlocal enabledelayedexpansion
TITLE 获取cloudflare IP
curl https://anycast.freecdn.workers.dev -o ip1.txt -#
TITLE 获取cloudflare可用IP段
Call :获取IP段 ip1.txt &&Call :删除重复行 ip2.txt
TITLE 当前可用IP段(推荐选择：104.19、104.18或172.67)
echo 当前可用IP段(推荐选择：104.19、104.18或172.67.)
echo =========================================================
rem type ip2.txt|findstr /I /V "1.1. 1.0. 173.245. 103.21."
type ip2.txt|findstr "."
echo =========================================================
set /p IP-CS=请输入需要测速的IP段：
findstr "%IP-CS%" ip1.txt > ip.txt
Call :取前N个 ip.txt
cls
echo =========================================================
TITLE %IP-CS% IP段选出%count%测速中…………
echo %IP-CS% IP段选出%count%测速中…………
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
TITLE 等待测速进程结束,…………大约需要15秒
echo 等待测速进程结束,…………大约需要15秒
echo =========================================================
choice /t 15 /d y /n >nul
cls
dir /o:-s temp > ip1.txt
findstr "%IP-CS%" ip1.txt > ip.txt
Call :N个IP ip.txt
cls
echo =========================================================
TITLE 测速成功%countIP%个IP排序结果（请选择排最前面的IP!）
echo  测速成功%countIP%个IP排序结果（请选择排最前面的IP!）
echo ---------------------------------------------------------
echo 时间			单位时间下载字节	IP
echo ---------------------------------------------------------
type ip.txt|findstr ":"
echo ---------------------------------------------------------
echo  测速成功%countIP%个IP排序结果（请选择排最前面的IP!）
echo =========================================================
rd /s /q "%~dp0temp"
del ip.txt ip1.txt sleep.vbs ip2.txt
pause&goto :eof

:删除重复行
sort %1>%1_tmp.txt
echo.>%1
for /f "delims=" %%i in (%1_tmp.txt) do (if not defined %%i set %%i=A & echo %%i>>%1)
del %1_tmp.txt >nul
goto :eof

:获取IP段
sort %1>%1_tmp.txt
echo.>ip2.txt
for /f "tokens=1,2 delims=." %%i in (%1_tmp.txt) do (echo %%i.%%j.>>ip2.txt)
del %1_tmp.txt >nul
goto :eof

:取前N个
sort %1>%1_tmp.txt
echo.>%1
set count=0
for /f "tokens=1,2" %%a in (%1_tmp.txt) do (
echo %%a >> %1
set /a count+=1
if !count! equ 66 del %1_tmp.txt >nul&&goto :eof
)
del %1_tmp.txt >nul
goto :eof

:N个IP
set countIP=0
for /f "tokens=1,2" %%a in (%1) do (set /a countIP+=1)
goto :eof

pause&goto :eof
