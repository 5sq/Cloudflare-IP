@echo off
setlocal enabledelayedexpansion
set tph=%tmp%\cfip\
if EXIST %tph% rd /s /q %tph%
mkdir %tph%
type nul >%tph%ip.txt
echo ==================================================================
type CDNym.txt>%tph%ip.txt
::Call :dnsip
echo ==================================================================
Call :pings  %tph%ip.txt
call :N��IP %tph%ip.txt
echo ping ͨ�� %countIP% ��IP��
echo ==================================================================
call :ȡǰN�� %tph%ip.txt 32
Call :CFPort %tph%ip.txt
type %tph%ip.txt
echo ==================================================================
Call :N��IP %tph%ip.txt
echo  CFIP 443�˿ڲ��Գɹ��� %countIP% ��IP
TITLE CFIP 443�˿ڲ��Գɹ��� %countIP% ��IP
echo ==================================================================

pause
goto :eof

:dnsip
set /a n=0
Set CFname=www.cloudflare.com dash.cloudflare.com blog.cloudflare.com
type nul >%tph%ip.txt
for %%a in (%CFname%) do (
Call :nslookupIP %%a&&set /a n+=1&&echo !n!�� DNS��ѯ���� %%a IP�� !ip12!
Set ip31=0&Set /a ip32=1+255&Call :����IP 1
)
goto :eof

:pings
type nul >%tph%temp.csv
set /a n=0
for /f %%i in ('type %1') do (ping -n 1 -w 20 %%i | find "ʱ��=" >> %tph%temp.csv&&set /a n+=1&&TITLE  ping IP��%%i/!n!)
type nul > %1
for /f "tokens=1-5 delims= " %%a in (%tph%temp.csv) do (echo %%a,%%b,%%c,%%d,%%e>>%1)
type nul >%tph%temp.csv
for /f "tokens=1-5 delims=," %%a in (%1) do (echo %%e,%%b,%%d>>%tph%temp.csv)
sort %tph%temp.csv >%1
type nul >%tph%temp.csv
for /f "tokens=1-4 delims=," %%a in (%1) do (echo %%b,	%%a>>%tph%temp.csv)
type %tph%temp.csv >%1
goto :eof

:ȡǰN��
type %1>%tph%_tmp.txt
type nul > %1
set count=0
for /f "delims=" %%a in (%tph%_tmp.txt) do (
echo %%a>> %1
set /a count+=1
if !count! equ %2 goto :eof
)
goto :eof

:����IP
set /a numN=1
:again
if %numN% LEQ %1 (
set count=%ip31%
for /l %%i in (1,1,260)do (
Set /a u1=!random!%%255
TITLE  ����IP��%ip12%.!count!.!u1!
echo %ip12%.!count!.!u1!>> %tph%ip.txt
set /a count+=1
if !count! equ %ip32% goto :mea
	)
:mea
set /a numN+=1
goto :again
)
goto :eof

:N��IP
set countIP=0
for /f "delims=" %%a in (%1) do (set /a countIP+=1)
goto :eof

:CFPort
type nul > %tph%_tmp.txt
set /a men=0&set /a men1=0
for /f "tokens=1-2 delims=," %%a in (%1) do (
set /a men1+=1
tcping -n 1 -w 0.22 %%a 443 >NUL&&echo %%a,%%b>>%tph%_tmp.txt&&set /a men+=1&&TITLE �Ѳ��ԣ�!men!/%countIP% ���ӳɹ���!men!
if !men1! GEQ 32 timeout /T 5 /NOBREAK >NUL 2>NUL&&set /a men1=1
)
type %tph%_tmp.txt > %1
goto :eof

:nslookupIP
for /f "tokens=1,2 delims=. skip=5" %%a in ('nslookup %1')do (
    set "ip12=%%a.%%b"
)
goto :eof
