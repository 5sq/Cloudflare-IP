@echo off &chcp 936 >NUL&color A & cd "%~dp0" &TITLE cloudflareIP测速
setlocal enabledelayedexpansion
TITLE 获取cloudflare IP
forfiles /m Cloudflare-IP.txt /s /d -7 /c "cmd /c del /f /s /q @path" & cls
if not EXIST Cloudflare-IP.txt curl https://raw.githubusercontent.com/5sq/Cloudflare-IP/main/Cloudflare-IP.txt -o Cloudflare-IP.txt -#||echo 请到 https^://github.com/5sq/Cloudflare-IP 下载Cloudflare-IP.txt到当前目录。 & pause&goto :eof
if EXIST Cloudflare-IP.txt type Cloudflare-IP.txt >ip1.txt
set numN=%random%
set /a numN=numN%%60+40
findstr "%numN%" ip1.txt > ip.txt
Call :取前N个 ip.txt,255
CLS
echo ==================================================================
TITLE  随机选中%count%个IP测速中…………
echo 随机选中%count%个IP测速中…………
echo ==================================================================
if EXIST "%~dp0temp" rd /s /q "%~dp0temp"
mkdir temp
echo WScript.sleep 500 > sleep.vbs
Set /a a1=0
for /f "tokens=1,2" %%a in ('type "ip.txt"') do (
sleep.vbs
start /b curl --resolve speedtest.udpfile.com:443:%%a https://speedtest.udpfile.com/cache.png -o temp/%%a -s --connect-timeout 2 --max-time 10
set /a a1+=1
TITLE %%a 启动测速。%count%个IP已经测速 !a1! 个IP
echo %%a 启动测速
)
chcp 936 >NUL
echo ==================================================================
TITLE 等待测速进程结束,…………大约需要15秒
timeout /T 15 /NOBREAK
chcp 936 >NUL
dir /o:-s temp|findstr "%numN%"|findstr "%date:~0,10%"> ip.txt
dir /o:-s /b temp >ip1.txt
Call :取前N个 ip1.txt,5
Call :N个IP ip.txt
cls
echo ==================================================================
TITLE 测速成功%countIP%个IP
echo  测速成功%countIP%个IP
echo ---------------------------------------------------------
echo 时间			单位时间下载字节	IP
echo ---------------------------------------------------------
type ip.txt
echo ---------------------------------------------------------
echo  测速通过%countIP%个IP中下载速度最快的5个IP：
echo ---------------------------------------------------------
type ip1.txt
echo ==================================================================
rd /s /q "%~dp0temp"
del ip.txt ip1.txt sleep.vbs ip.txt_tmp.txt
pause&goto :eof

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
