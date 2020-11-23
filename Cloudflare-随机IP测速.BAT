@echo off &chcp 936 >NUL &color A & cd "%~dp0" &TITLE cloudflareIP测速
setlocal enabledelayedexpansion
TITLE 获取cloudflare IP
curl https://ip.193107.xyz/Cloudflare-IP.txt -o ip1.txt -#
set numN=%random%
set /a numN=numN%%60+40
findstr "%numN%" ip1.txt > ip.txt
Call :取前N个 ip.txt
CLS
echo =========================================================
TITLE  随机选中%count%个IP测速中…………
echo 随机选中%count%个IP测速中…………
echo =========================================================
if EXIST "%~dp0temp" rd /s /q "%~dp0temp"
mkdir temp
echo WScript.sleep 500 > sleep.vbs
Set /a a1=0
for /f "tokens=1,2" %%a in ('type "ip.txt"') do (
sleep.vbs
start /b curl --resolve speed.haoren.ml:443:%%a https://speed.haoren.ml/cache.jpg -o temp/%%a -s --connect-timeout 2 --max-time 10
set /a a1+=1
TITLE %%a 启动测速 !a1! 个IP
echo %%a 启动测速
)
chcp 936 >NUL
echo =========================================================
TITLE 等待测速进程结束,…………大约需要15秒
timeout /T 15 /NOBREAK
chcp 936 >NUL
dir /o:-s temp|findstr "%numN%"|findstr "%date:~0,10%"> ip.txt
Call :N个IP ip.txt
cls
echo =========================================================
TITLE 测速成功%countIP%个IP排序结果（请选择排最前面的IP!）
echo  测速成功%countIP%个IP排序结果（请选择排最前面的IP!）
echo ---------------------------------------------------------
echo 时间			单位时间下载字节	IP
echo ---------------------------------------------------------
type ip.txt
echo ---------------------------------------------------------
echo  测速成功%countIP%个IP排序结果（请选择排最前面的IP!）
echo =========================================================
rd /s /q "%~dp0temp"
del ip.txt ip1.txt sleep.vbs ip.txt_tmp.txt
pause&goto :eof

:取前N个
sort %1>%1_tmp.txt
echo.>%1
set count=0
for /f "tokens=1,2" %%a in (%1_tmp.txt) do (
echo %%a >> %1
set /a count+=1
if !count! equ 66 del %1_tmp.txt >nul&&goto :eof
)
goto :eof

:N个IP
set countIP=0
for /f "tokens=1,2" %%a in (%1) do (set /a countIP+=1)
goto :eof

pause&goto :eof
