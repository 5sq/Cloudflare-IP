@echo off
setlocal enabledelayedexpansion
set /a numN=%random%
set tph=%tmp%\%numN%\
if EXIST %tph% rd /s /q %tph%
mkdir %tph%
::==================================================================
rem �������ӻ�ɾ����Ҫ����������
Set CFname=www.cloudflare.com dash.cloudflare.com blog.cloudflare.com
rem �����Զ�������Ĳ��Զ˿�
set CFipPort=443
rem  ==================================================================
Call :dnsip
call :N��IP %tph%ip.txt
echo ==================================================================
set /a ti=%countIP%/5/50
echo tcping %countIP% ��IP��Լ��Ҫ%ti%���ӡ�������
echo ==================================================================
Call :tcpingCF  %tph%ip.txt
Call :N��IP %tph%ip.txt
type %tph%ip.txt
echo ==================================================================
echo  CFIP 443�˿ڲ��Գɹ��� %countIP% ��IP
TITLE CFIP 443�˿ڲ��Գɹ��� %countIP% ��IP
echo ==================================================================
rd /s /q %tph%
pause
goto :eof
pause&goto :eof

:tcpingCF
type nul >%tph%temp.csv
set /a n=0&set /a men1=0
for /f %%i in ('type %1') do (tcping -n 1 -w 0.22 -s %%i %CFipPor% | find "open" >> %tph%temp.csv&&set /a n+=1&&TITLE  tcping 443�˿����ӳɹ���%%i/!n!
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

:dnsip
echo ==================================================================
set /a n=0
type nul >%tph%ip.txt
for %%a in (%CFname%) do (
Call :nslookupIP %%a&&set /a n+=1&&echo DNS��ѯ���� %%a IP�� !ip12!
Set ip31=0&Set /a ip32=1+255&Call :����IP 1
)
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

:nslookupIP
for /f "tokens=1,2 delims=. skip=5" %%a in ('nslookup %1')do (
    set "ip12=%%a.%%b"
)
goto :eof


