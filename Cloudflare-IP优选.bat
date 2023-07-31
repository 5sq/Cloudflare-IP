@echo off
setlocal enabledelayedexpansion
set /a numN=%random%
set tph=%tmp%\%numN%\
if EXIST %tph% rd /s /q %tph%
mkdir %tph%
::==================================================================
rem 可以增加或删除你要解析的域名
Set CFname=www.cloudflare.com dash.cloudflare.com blog.cloudflare.com
rem 可以自定义下面的测试端口
set CFipPort=443
::==================================================================
Call :dnsip
call :N个IP %tph%ip.txt
echo ==================================================================
set /a ti=%countIP%/4/60
echo ping %countIP% 个IP大约需要%ti%分钟…………
echo ==================================================================
Call :pings  %tph%ip.txt
call :N个IP %tph%ip.txt
echo ping 通的 %countIP% 个IP。选取前32个IP tcping %CFipPort% 端口
echo ==================================================================
call :取前N个 %tph%ip.txt 32
Call :tcpingCF %tph%ip.txt
type %tph%ip.txt
echo ==================================================================
Call :N个IP %tph%ip.txt
echo  tcping %CFipPort%  端口测试成功的 %countIP% 个IP
TITLE tcping %CFipPort%  端口测试成功的 %countIP% 个IP
echo ==================================================================
rd /s /q %tph%
pause&goto :eof

:dnsip
echo ==================================================================
set /a n=0
type nul >%tph%ip.txt
for %%a in (%CFname%) do (
Call :nslookupIP %%a&&set /a n+=1&&echo DNS查询到的 %%a IP段 !ip12!
Set ip31=0&Set /a ip32=1+255&Call :生成IP 1
)
goto :eof

:pings
type nul >%tph%temp.csv
set /a n=0
for /f %%i in ('type %1') do (ping -n 1 -w 10 %%i | find "时间=" >> %tph%temp.csv&&set /a n+=1&&TITLE  ping %countIP% 个IP，成功：%%i/!n!)
type nul > %1
for /f "tokens=1-5 delims= " %%a in (%tph%temp.csv) do (echo %%a,%%b,%%c,%%d,%%e>>%1)
type nul >%tph%temp.csv
for /f "tokens=1-5 delims=," %%a in (%1) do (echo %%e,%%b,%%d>>%tph%temp.csv)
sort %tph%temp.csv >%tph%temp1.csv&type nul >%1
for /f "tokens=1-4 delims=," %%a in (%tph%temp1.csv) do (echo %%b,	%%a>>%1)
goto :eof

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

:生成IP
set /a numN=1
:again
if %numN% LEQ %1 (
set count=%ip31%
for /l %%i in (1,1,260)do (
Set /a u1=!random!%%255
TITLE  生成IP：%ip12%.!count!.!u1!
echo %ip12%.!count!.!u1!>> %tph%ip.txt
set /a count+=1
if !count! equ %ip32% goto :mea
	)
:mea
set /a numN+=1
goto :again
)
goto :eof

:N个IP
set countIP=0
for /f "delims=" %%a in (%1) do (set /a countIP+=1)
goto :eof

:tcpingCF
type nul >%tph%temp.csv
set /a n=0&set /a men1=0
for /f "tokens=1-2 delims=," %%i in ('type %1') do (tcping -n 1 -w 0.23 -s %%i %CFipPort% | find "open" >> %tph%temp.csv&&set /a n+=1&&TITLE  tcping %CFipPort%端口连接成功：%%i/!n!
set /a men1+=1
if !men1! GEQ 32 timeout /T 2 /NOBREAK >NUL 2>NUL&&set /a men1=1
)
type nul > %1
for /f "tokens=1-8 delims= " %%a in (%tph%temp.csv) do (echo %%a,%%b,%%c,%%d,%%e,%%f,%%g,%%h>>%1)
type nul >%tph%temp.csv
for /f "tokens=1-8 delims=," %%a in (%1) do (echo %%h,%%b>>%tph%temp.csv)
sort %tph%temp.csv >%1&type nul >%tph%temp.csv
for /f "tokens=1-2 delims=," %%a in (%1) do (echo %%b,	%%a>>%tph%temp.csv)
type nul >%1
for /f "tokens=1-2 delims=:" %%a in (%tph%temp.csv) do (echo %%a,	%%b>>%1)
goto :eof

:nslookupIP
for /f "tokens=1,2 delims=. skip=5" %%a in ('nslookup %1')do (
    set "ip12=%%a.%%b"
)
goto :eof
