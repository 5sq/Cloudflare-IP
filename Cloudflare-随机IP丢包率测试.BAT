@echo off &chcp 936 >NUL&color A & cd "%~dp0" &TITLE cloudflareIP测速
CLS
setlocal enabledelayedexpansion
:menu
set numN=%random%
set /a numN=numN%%30+70
if %numN% equ 72 goto :menu
if %numN% equ 90 goto :menu
if %numN% equ 93 goto :menu
if %numN% equ 98 goto :menu
set tph=%tmp%\%numN%\
mkdir %tph%
TITLE 获取cloudflare IP
forfiles /m Cloudflare-IP.txt /s /d -100 /c "cmd /c del /f /s /q @path" & cls
if not EXIST Cloudflare-IP.txt echo 请到 https^://github.com/5sq/Cloudflare-IP 下载Cloudflare-IP.txt到当前目录。 && pause&&goto :eof
type Cloudflare-IP.txt > %tph%ip1.txt
findstr "%numN%" %tph%ip1.txt > %tph%ip.txt
Call :N个IP %tph%ip.txt
echo ==================================================================
Set tip=%countIP%
title 测试%countIP% CF节点ICMP 丢包率
echo 测试%countIP% CF节点ICMP 丢包率
echo ==================================================================
Call :PingCF
echo ==================================================================
Call :N个IP %tph%SortIP.csv
echo CF可用IP %tip% 个；CF节点ICMP测试，没有丢包的 %countIP% 个IP。
title CF可用IP %tip% 个； CF节点ICMP测试，没有丢包的 %countIP% 个IP。
echo CF可用IP,响应时间 > %numN%_%countIP%个CF可用_IP.txt
type %tph%SortIP.csv >> %numN%_%countIP%个CF可用_IP.txt
echo ==================================================================
Call :meta3 %tph%SortIP.csv
echo ==================================================================
rd /s /q %tph%
pause&goto :eof

:取前N个
type %1>%tph%_tmp.txt
type nul > %1
set count=0
for /f "delims=" %%a in (%tph%_tmp.txt) do (
echo %%a>> %1
set /a count+=1
if !count! equ %2 goto :eof
)
goto :eof

:N个IP
set countIP=0
for /f "delims=" %%a in (%1) do (set /a countIP+=1)
goto :eof

:PingCF
if EXIST "%tph%tmp" rd /s /q "%tph%tmp"
mkdir %tph%tmp
type nul > %tph%ping.csv
set n=30
Set n1=1
powershell -c "$n=1;$m=1;gc '%tph%ip.txt'|%%{$f='%tph%tmp\'+$m+'.txt';$_>>$f;if($n%%%n% -eq 0){$m++};$n++}" 
for /r "%tph%tmp" %%i in (*.txt) do (
set /a n2=!n1!*30
if !n2! GTR %countIP% set /a n2=%countIP%
title 已测试 !n2!/%countIP% CF节点ICMP 丢包率
if EXIST %%i more %%i>%tph%a.txt
if EXIST %tph%a.txt fping -f %tph%a.txt -c 5 --interval=0 -s >%tph%temp.csv
if EXIST %tph%temp.csv more +1 %tph%temp.csv>>%tph%ping.csv
if EXIST %%i del %%i
if EXIST %tph%a.txt del %tph%a.txt
set /a n1+=1
)
if EXIST "%tph%tmp" rd /s /q "%tph%tmp"
more %tph%ping.csv>%tph%temp.csv
cls
echo ==================================================================
echo IP地址		发送	接收	平均	最少	最多	
echo ==================================================================
setlocal
del %tph%ping.csv
for /f "tokens=1-7 delims=," %%a in (%tph%temp.csv) do (if %%d equ 5 (echo %%a,%%b,%%c,%%d,%%e,%%f,%%g>>%tph%ping.csv))
del %tph%temp.csv
for /F "tokens=1-7 delims=," %%a in (%tph%ping.csv) do set "a[%%e,%%f,%%g,%%a,%%b,%%c,%%d]=%%"
del %tph%ping.csv
for /F "tokens=1-8 delims=[,]=" %%a in ('set a[') do echo %%a,%%b,%%c,%%d,%%e,%%f,%%g,%%h >>%tph%ping.csv
del %tph%ip.txt %tph%tmp.csv %tph%temp.csv
type nul > %tph%SortIP.csv
for /F "tokens=1-8 delims=," %%a in (%tph%ping.csv) do (
echo %%e	%%g	%%h	%%b	%%c	%%d
echo %%e,%%b >> %tph%SortIP.csv
)
endlocal
goto :eof

:meta3
for /f "tokens=1 delims=, skip=1" %%i in (%1) do (set cfip=%%i&&goto :next)
:next
echo !cfip! CF节点连接测试回应：
curl --resolve www.cloudflare.com:443:!cfip! https://www.cloudflare.com/cdn-cgi/trace
goto :eof


pause&goto :eof

