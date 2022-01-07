@echo off &chcp 936 >NUL&color A & cd "%~dp0" &TITLE cloudflareIP测速
CLS
setlocal enabledelayedexpansion
TITLE 获取cloudflare IP
forfiles /m Cloudflare-IP.txt /s /d -100 /c "cmd /c del /f /s /q @path" & cls
if not EXIST Cloudflare-IP.txt echo 请到 https^://github.com/5sq/Cloudflare-IP 下载Cloudflare-IP.txt到当前目录。 && pause&&goto :eof
type Cloudflare-IP.txt > ip1.txt
set numN=%random%
set /a numN=numN%%60+40
findstr "%numN%" ip1.txt > ip.txt
Call :N个IP ip.txt
set /a nu=%countIP%/30*30
Call :取前N个 ip.txt,%nu%
Call :取前N个 ip.txt,210
Call :N个IP ip.txt
echo ==================================================================
title 测试%countIP% CF节点ICMP 丢包率
echo 测试%countIP% CF节点ICMP 丢包率
echo ==================================================================
Call :PingCF
echo ==================================================================
Call :N个IP ip.txt
echo CF节点ICMP测试，没有丢包的 %countIP% 个IP:
echo ==================================================================
type ip.txt
echo ==================================================================
Call :meta
echo ==================================================================
type ip.txt >没有丢包的%countIP%个IP.txt
del /q ip.txt ip1.txt ping.csv
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
if EXIST "%~dp0tmp" rd /s /q "%~dp0tmp"
mkdir tmp
if EXIST ping.csv del ping.csv
set n=30
Set n1=1
powershell -c "$n=1;$m=1;gc 'ip.txt'|%%{$f='tmp\'+$m+'.txt';$_>>$f;if($n%%%n% -eq 0){$m++};$n++}" 
for /r "%~dp0tmp" %%i in (*.txt) do (
set /a n2=!n1!*30
if !n2! GTR %countIP% set /a n2=%countIP%
title 已测试 !n2!/%countIP% CF节点ICMP 丢包率
if EXIST %%i more %%i>a.txt
if EXIST a.txt fping -f a.txt -c 20 --interval=0 -s >temp.csv
if EXIST temp.csv more +1 temp.csv>>ping.csv
if EXIST %%i del %%i
if EXIST a.txt del a.txt
set /a n1+=1
)
if EXIST "%~dp0tmp" rd /s /q "%~dp0tmp"
more ping.csv>temp.csv
echo ==================================================================
echo IP地址		发送	接收	平均	最少	最多	
echo ==================================================================
setlocal
del ping.csv
for /f "tokens=1-7 delims=," %%a in (temp.csv) do (if %%d equ 20 (echo %%a,%%b,%%c,%%d,%%e,%%f,%%g>>ping.csv))
del temp.csv
for /F "tokens=1-7 delims=," %%a in (ping.csv) do set "a[%%e,%%f,%%g,%%a,%%b,%%c,%%d]=%%"
del ping.csv
for /F "tokens=1-8 delims=[,]=" %%a in ('set a[') do echo %%a,%%b,%%c,%%d,%%e,%%f,%%g,%%h >>ping.csv
del ip.txt tmp.csv temp.csv
set count=0
for /F "tokens=1-8 delims=," %%a in (ping.csv) do (
set /a count+=1
echo %%e	%%g	%%h	%%b	%%c	%%d
echo %%e >>ip.txt
)
endlocal
goto :eof

:meta
setlocal enabledelayedexpansion
if EXIST meta.txt del meta.txt
	for /f "delims=" %%a in ('curl --ipv4 --retry 3 -s https://speed.cloudflare.com/meta') do (
	set str=%%a
	set str=!str:{=!
	set str=!str:}=!
	set str=!str:"=!
	echo !str:,=%;!
	)>meta.txt
for /f "tokens=1 delims=;" %%i in (meta.txt) do (
set str=%%i
echo !str:hostname=远端主机名! 
)
for /f "tokens=2 delims=;" %%i in (meta.txt) do (
set str=%%i
echo !str:clientIp=本机公网IP! 
)
for /f "tokens=4 delims=;" %%i in (meta.txt) do (
set str=%%i
echo !str:asn=自治域 AS! 
)
for /f "tokens=5 delims=;" %%i in (meta.txt) do (
set str=%%i
echo !str:colo=数据中心! 
)
for /f "tokens=6 delims=;" %%i in (meta.txt) do (
set str=%%i
echo !str:country=所在国家! 
)
for /f "tokens=7 delims=;" %%i in (meta.txt) do (
set str=%%i
echo !str:city=所在城市!
)
for /f "tokens=8 delims=;" %%i in (meta.txt) do (
set str=%%i
echo !str:latitude=纬度! 
)
for /f "tokens=9 delims=;" %%i in (meta.txt) do (
set str=%%i
echo !str:longitude=经度! 
)
del meta.txt
goto :eof

pause&goto :eof
