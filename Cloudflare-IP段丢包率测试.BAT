@echo off &chcp 936 >NUL &  color A & cd "%~dp0" &TITLE cloudflareIP测速
setlocal enabledelayedexpansion
TITLE 获取cloudflare IP

cls
TITLE 当前可用IP段(推荐选择：104.19、104.18、104.17、104.16)
echo 当前可用IP段(推荐选择：104.19、104.18、104.17、104.16)
echo ==================================================================
echo 1、（104.16）
echo 2、（104.17）
echo 3、（104.18）
echo 4、（104.19）
echo 5、（104.21）
echo 6、（104.24）
echo 7、（104.25）
echo 8、（104.27）
echo 9、（162.159）
echo a、（172.64）
echo b、（172.67）
echo c、（190.93）
echo d、（198.41）
echo 0、（退出）
echo ==================================================================
set /p IP-CS=请选择IP段菜单：
set tph=%tmp%\%IP-CS%\
if EXIST %tph% rd /s /q %tph%
mkdir %tph%
if %IP-CS%==1 Set ip12=104.16&Set ip31=0&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==2 Set ip12=104.17&Set ip31=0&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==3 Set ip12=104.18&Set ip31=0&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==4 Set ip12=104.19&Set ip31=0&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==5 Set ip12=104.21&Set ip31=0&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==6 Set ip12=104.24&Set ip31=0&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==7 Set ip12=104.25&Set ip31=0&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==8 Set ip12=104.27&Set ip31=0&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==9 Set ip12=162.159&Set ip31=0&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==a Set ip12=172.64&Set ip31=0&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==b Set ip12=172.67&Set ip31=0&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==c Set ip12=190.93&Set ip31=240&Set /a ip32=1+255&Call :生成IP
if %IP-CS%==d Set ip12=198.41&Set ip31=128&Set /a ip32=1+255&Call :生成IP 
if %IP-CS%==0 exit
echo ==================================================================
echo 测试连接CF节点可用IP…………
set /a a=1
Call :CF可用IP  %tph%ip.txt
Call :N个IP %tph%ip.txt
echo ==================================================================
title 测试%countIP% CF节点ICMP 丢包率
echo 测试%countIP% CF节点ICMP 丢包率
echo ==================================================================
Call :PingCF
echo ==================================================================
Call :N个IP %tph%tip.txt
Set tip=%countIP%
Call :N个IP %tph%SortIP.csv
echo CF可用IP %tip% 个；CF节点ICMP测试，没有丢包的 %countIP% 个IP。
title CF可用IP %tip% 个；CF节点ICMP测试，没有丢包的 %countIP% 个IP。
echo CF可用IP,响应时间 > %ip12%_%countIP%个CF可用IP.csv
type %tph%SortIP.csv >> %ip12%_%countIP%个CF可用IP.csv
echo ==================================================================
Call :meta3
echo ==================================================================
rd /s /q %tph%
pause&goto :eof


:生成IP
set count=%ip31%
type nul >%tph%ip.txt
for /l %%i in (1,1,260)do (
Set /a u1=!random!%%255
TITLE  生成IP：%ip12%.!count!.!u1!
echo %ip12%.!count!.!u1!>> %tph%ip.txt
set /a count+=1
if !count! equ %ip32% goto :eof
)
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
del %tph%ip.txt
type nul > %tph%SortIP.csv 
for /F "tokens=1-8 delims=," %%a in (%tph%ping.csv) do (
echo %%e	%%g	%%h	%%b	%%c	%%d
echo %%e,%%b >> %tph%SortIP.csv 
)
endlocal
goto :eof

:jip
for /f "tokens=1 delims=," %%i in (%1) do (
set cfip=%%i
)
goto :eof

:meta3
Call :jip %tph%SortIP.csv
echo !cfip! CF节点连接测试回应：
curl --ipv4 --retry 3 --resolve www.cloudflare.com:443:!cfip! https://www.cloudflare.com/cdn-cgi/trace
goto :eof

:CF可用IP
if !a! LEQ 5 (
if EXIST "%tph%temp" rd /s /q "%tph%temp"
mkdir %tph%temp
for /f "delims=" %%a in (%1) do (start /b curl --resolve www.cloudflare.com:443:%%a https://www.cloudflare.com/cdn-cgi/trace -o %tph%temp\%%a -s --connect-timeout 1 --max-time 2 && TITLE CF节点第 !a! 批次连接测试；CF可用IP:%%a)
timeout /T 3 /NOBREAK >nul&&dir /o:-s /b %tph%temp >%1&&dir /o:-s %tph%temp\|findstr "%date:~0,10%"|findstr /I /V "dir">%tph%tip.txt&&rd /s /q %tph%temp&&Call :N个IP %tph%tip.txt
echo 完成第 !a! 次 www.cloudflare.com 连接测试；可用IP：!countIP! 个。
set /a a=a+1
goto CF可用IP
)
goto :eof

pause&goto :eof

==================bak==================

103.21.244.0/22		103.21.244.1  到 103.21.247.254
103.22.200.0/22		103.22.200.1  到 103.22.203.254
103.31.4.0/22		103.31.0.1  到 103.31.3.254
104.16.0.0/13		255.16.0.1  到 255.23.255.254
104.24.0.0/14		104.24.0.1  到 104.27.255.254
108.162.192.0/18	108.162.192.1  到 108.162.255.254
131.0.72.0/22		131.0.72.1  到 131.0.75.254
141.101.64.0/18		141.101.64.1  到 141.101.127.254
162.158.0.0/15		162.158.0.1  到 162.159.255.254
172.64.0.0/13		172.64.0.1  到 172.71.255.254
173.245.48.0/20		173.245.48.1  到 173.245.63.254
188.114.96.0/20		188.114.96.1  到 188.114.111.254
190.93.240.0/20		190.93.240.1  到 190.93.255.254
197.234.240.0/22	197.234.240.1  到 197.234.243.254
198.41.128.0/17		198.41.128.1  到 198.41.255.254
