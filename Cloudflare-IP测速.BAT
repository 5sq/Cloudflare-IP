@echo off &chcp 936 >NUL &  color A & cd "%~dp0" &TITLE cloudflareIP测速
setlocal enabledelayedexpansion
TITLE 获取cloudflare IP
forfiles /m Cloudflare-IP.txt /s /d -7 /c "cmd /c del /f /s /q @path" & cls
if not EXIST Cloudflare-IP.txt curl https://ip.193107.xyz/Cloudflare-IP.txt -o Cloudflare-IP.txt -#
if EXIST Cloudflare-IP.txt type Cloudflare-IP.txt >ip1.txt
TITLE 获取cloudflare可用IP段
Call :获取IP段 ip1.txt 
TITLE 删除重复IP段
Call :删除重复行 ip2.txt
TITLE 当前可用IP段(推荐选择：104.19、104.16或172.67)
echo 当前可用IP段(推荐选择：104.19、104.16或172.67.)
echo =========================================================
type ip2.txt|findstr "."
echo =========================================================
set /p IP-CS=请输入需要测速的IP段：
findstr "%IP-CS%" ip1.txt > ip2.txt
sort /+9 ip2.txt > ip.txt
Call :取前N个 ip.txt,66
cls
echo =========================================================
TITLE %IP-CS% IP段选出%count%测速中…………
echo %IP-CS% IP段选出%count%测速中…………
echo =========================================================
if EXIST "%~dp0temp" rd /s /q "%~dp0temp"
mkdir temp
echo WScript.sleep 500 > sleep.vbs
Set /a a1=0
for /f "tokens=1,2" %%a in ('type "ip.txt"') do (
sleep.vbs
start /b curl --resolve speed.haoren.ml:443:%%a https://speed.haoren.ml/cache.jpg -o temp/%%a -s --connect-timeout 2 --max-time 10
set /a a1+=1
TITLE %%a 启动测速。已经测速 !a1! 个IP
echo %%a 启动测速
)
chcp 936 >NUL
echo =========================================================
TITLE 等待测速进程结束,…………大约需要15秒
timeout /T 15 /NOBREAK
cls
chcp 936 >NUL
dir /o:-s temp|findstr "%IP-CS%"|findstr "%date:~0,10%"> ip.txt
dir /o:-s /b temp >ip1.txt
Call :取前N个 ip1.txt,5
Call :N个IP ip.txt
cls
echo =========================================================
TITLE 测速成功%countIP%个IP！
echo  测速成功%countIP%个IP！
echo ---------------------------------------------------------
echo 时间			单位时间下载字节	IP
echo ---------------------------------------------------------
type ip.txt
echo ---------------------------------------------------------
echo  测速通过%countIP%个IP中下载速度最快的5个IP：
echo ---------------------------------------------------------
type ip1.txt
echo =========================================================
rd /s /q "%~dp0temp"
del ip.txt ip1.txt sleep.vbs ip2.txt
pause&goto :eof

:删除重复行
sort %1>%1_tmp.txt
echo.>%1
for /f "delims=" %%i in (%1_tmp.txt) do (if not defined %%i set %%i=A & TITLE 删除重复IP：%%i & echo %%i>>%1)
del %1_tmp.txt >nul
goto :eof

:获取IP段
sort %1>%1_tmp.txt
echo.>ip2.txt
for /f "tokens=1,2 delims=." %%i in (%1_tmp.txt) do (TITLE 获取cloudflare可用IP段：%%i.%%j & echo %%i.%%j>>ip2.txt)
del %1_tmp.txt >nul
goto :eof

:取前N个
type %1>%1_tmp.txt
del %1
set count=0
for /f "tokens=1,2" %%a in (%1_tmp.txt) do (
echo %%a >> %1
set /a count+=1
if !count! equ %2 del %1_tmp.txt >nul&&goto :eof
)
del %1_tmp.txt >nul
goto :eof

:N个IP
set countIP=0
for /f "tokens=1,2" %%a in (%1) do (set /a countIP+=1)
goto :eof

pause&goto :eof
