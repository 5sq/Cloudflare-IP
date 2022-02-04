@echo off &chcp 936 >NUL&color A & cd "%~dp0" &TITLE cloudflareIP测速
CLS
setlocal enabledelayedexpansion
:menu
set numN=%random%
set /a numN=numN%%50+50
if %numN% equ 59 goto :menu
if %numN% equ 62 goto :menu
if %numN% equ 64 goto :menu
if %numN% equ 67 goto :menu
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
echo ==================================================================
echo 测试连接CF节点可用IP…………
Call :CF可用IP  %tph%ip.txt
Call :N个IP %tph%ip.txt
set /a nu=%countIP%/30*30
Call :取前N个 %tph%ip.txt,%nu%
Call :取前N个 %tph%ip.txt,300
Call :N个IP  %tph%ip.txt
echo CF可用IP: %countIP% 个
echo ==================================================================
title 测试%countIP% CF节点ICMP 丢包率
echo 测试%countIP% CF节点ICMP 丢包率
echo ==================================================================
Call :PingCF
echo ==================================================================
Call :N个IP %tph%SortIP.csv
echo CF节点ICMP测试，没有丢包的 %countIP% 个IP:
title  CF节点ICMP测试，没有丢包的 %countIP% 个IP:
echo CF可用IP,响应时间 > %numN%_%countIP%个CF可用IP.csv
type %tph%SortIP.csv >> %numN%_%countIP%个CF可用IP.csv
echo ==================================================================
Call :meta
echo ==================================================================
rd /s /q %tph%
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

:PingCF
if EXIST "%tph%tmp" rd /s /q "%tph%tmp"
mkdir %tph%tmp
if EXIST %tph%ping.csv del %tph%ping.csv
set n=30
Set n1=1
powershell -c "$n=1;$m=1;gc '%tph%ip.txt'|%%{$f='%tph%tmp\'+$m+'.txt';$_>>$f;if($n%%%n% -eq 0){$m++};$n++}" 
for /r "%tph%tmp" %%i in (*.txt) do (
set /a n2=!n1!*30
if !n2! GTR %countIP% set /a n2=%countIP%
title 已测试 !n2!/%countIP% CF节点ICMP 丢包率
if EXIST %%i more %%i>%tph%a.txt
if EXIST %tph%a.txt fping -f %tph%a.txt -c 10 --interval=0 -s >%tph%temp.csv
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
for /f "tokens=1-7 delims=," %%a in (%tph%temp.csv) do (if %%d equ 10 (echo %%a,%%b,%%c,%%d,%%e,%%f,%%g>>%tph%ping.csv))
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

:meta
setlocal enabledelayedexpansion
Call :jip %tph%SortIP.csv
echo !cfip!CF节点连接测试回应：
type nul > %tph%meta.txt
 	for /f "delims=" %%a in ('curl --resolve speed.cloudflare.com:443:!cfip! --ipv4 --retry 3 -s https://speed.cloudflare.com/meta') do (
	set str=%%a
	set str=!str:{=!
	set str=!str:}=!
	set str=!str:"=!
	echo !str!
	)>  %tph%meta.txt
	
set /a a=1
:meta2
if %a% LEQ 15 (
for /f "tokens=%a% delims=," %%i in (%tph%meta.txt) do (
set str=%%i
echo !str! 
)
set /a a=%a%+1
goto meta2
)
goto :eof

:jip
for /f "tokens=1 delims=," %%i in (%1) do (
set cfip=%%i
)
goto :eof

:CF可用IP
if EXIST "%tph%temp" rd /s /q "%tph%temp"
mkdir %tph%temp
for /f "delims=" %%a in (%1) do (start /b curl --resolve www.cloudflare.com:443:%%a https://www.cloudflare.com/cdn-cgi/trace -o %tph%temp\%%a -s --connect-timeout 1 --max-time 2 && TITLE  CF可用IP:%%a)
timeout /T 3 /NOBREAK
dir /o:-s /b %tph%temp >%1
goto :eof


pause&goto :eof

