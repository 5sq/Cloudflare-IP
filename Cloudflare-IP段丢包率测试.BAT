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
echo 5、（172.64）
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
rem Call :取前N个 %tmp%\ip.txt,30
Call :N个IP %tmp%\ip.txt
echo ==================================================================
title 测试%countIP% CF节点ICMP 丢包率
echo 测试%countIP% CF节点ICMP 丢包率
echo ==================================================================
Call :PingCF
echo ==================================================================
Call :N个IP %tmp%\ip.txt
echo CF节点ICMP测试，没有丢包的 %countIP% 个IP:
title CF节点ICMP测试，没有丢包的 %countIP% 个IP:
echo ==================================================================
Call :meta
echo ==================================================================
del %tmp%\ip.txt %tmp%\ip2.txt %tmp%\meta.txt %tmp%\ping.csv
pause&goto :eof


:生成IP
set count=%ip31%
type nul >%tmp%\ip.txt
for /l %%i in (1,1,260)do (
Set /a u1=!random!%%60+40
TITLE  生成IP：%ip12%.!count!.!u1!
echo %ip12%.!count!.!u1!>> %tmp%\ip.txt
set /a count+=1
if !count! equ %ip32% goto :eof
)
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

:PingCF
if EXIST "%tmp%\tmp" rd /s /q "%tmp%\tmp"
mkdir %tmp%\tmp
if EXIST %tmp%\ping.csv del %tmp%\ping.csv
set n=30
Set n1=1
powershell -c "$n=1;$m=1;gc '%tmp%\ip.txt'|%%{$f='%tmp%\tmp\'+$m+'.txt';$_>>$f;if($n%%%n% -eq 0){$m++};$n++}" 
for /r "%tmp%\tmp" %%i in (*.txt) do (
set /a n2=!n1!*30
if !n2! GTR %countIP% set /a n2=%countIP%
title 已测试 !n2!/%countIP% CF节点ICMP 丢包率
if EXIST %%i more %%i>%tmp%\a.txt
if EXIST %tmp%\a.txt fping -f %tmp%\a.txt -c 20 --interval=0 -s >%tmp%\temp.csv
if EXIST %tmp%\temp.csv more +1 %tmp%\temp.csv>>%tmp%\ping.csv
if EXIST %%i del %%i
if EXIST %tmp%\a.txt del %tmp%\a.txt
set /a n1+=1
)
if EXIST "%tmp%\tmp" rd /s /q "%tmp%\tmp"
more %tmp%\ping.csv>%tmp%\temp.csv
cls
echo ==================================================================
echo IP地址		发送	接收	平均	最少	最多	
echo ==================================================================
setlocal
del %tmp%\ping.csv
for /f "tokens=1-7 delims=," %%a in (%tmp%\temp.csv) do (if %%d equ 20 (echo %%a,%%b,%%c,%%d,%%e,%%f,%%g>>%tmp%\ping.csv))
del %tmp%\temp.csv
for /F "tokens=1-7 delims=," %%a in (%tmp%\ping.csv) do set "a[%%e,%%f,%%g,%%a,%%b,%%c,%%d]=%%"
del %tmp%\ping.csv
for /F "tokens=1-8 delims=[,]=" %%a in ('set a[') do echo %%a,%%b,%%c,%%d,%%e,%%f,%%g,%%h >>%tmp%\ping.csv
del %tmp%\ip.txt %tmp%\tmp.csv %tmp%\temp.csv
Call :N个IP %tmp%\ping.csv
echo IP地址,平均延迟> 没有丢包的%countIP%个IP.csv
for /F "tokens=1-8 delims=," %%a in (%tmp%\ping.csv) do (
echo %%e	%%g	%%h	%%b	%%c	%%d
echo %%e >>%tmp%\ip.txt
echo %%e,%%b >> 没有丢包的%countIP%个IP.csv
)
endlocal
goto :eof

:meta
setlocal enabledelayedexpansion
Call :jip %tmp%\ip.txt
if EXIST %tmp%\meta.txt del %tmp%\meta.txt
 	for /f "delims=" %%a in ('curl --resolve speed.cloudflare.com:443:!cfip! --ipv4 --retry 3 -s https://speed.cloudflare.com/meta') do (
	set str=%%a
	set str=!str:{=!
	set str=!str:}=!
	set str=!str:"=!
	echo !str:,=%;!
	)>%tmp%\meta.txt

for /f "tokens=1 delims=;" %%i in (%tmp%\meta.txt) do (
set str=%%i
echo !str:hostname=远端主机名! 
)
for /f "tokens=2 delims=;" %%i in (%tmp%\meta.txt) do (
set str=%%i
echo !str:clientIp=本机公网IP! 
)
for /f "tokens=4 delims=;" %%i in (%tmp%\meta.txt) do (
set str=%%i
echo !str:asn:=自治域:AS! 
)
for /f "tokens=5 delims=;" %%i in (%tmp%\meta.txt) do (
set str=%%i
echo !str:colo=数据中心! 
)
for /f "tokens=6 delims=;" %%i in (%tmp%\meta.txt) do (
set str=%%i
echo !str:country=所在国家! 
)
for /f "tokens=7 delims=;" %%i in (%tmp%\meta.txt) do (
set str=%%i
echo !str:city=所在城市!
)
for /f "tokens=8 delims=;" %%i in (%tmp%\meta.txt) do (
set str=%%i
echo !str:latitude=纬度! 
)
for /f "tokens=9 delims=;" %%i in (%tmp%\meta.txt) do (
set str=%%i
echo !str:longitude=经度! 
)
del %tmp%\meta.txt
goto :eof

:jip
set cfip=aa
for /f "delims=" %%i in (%1) do (
set cfip=%%i
echo 解析IP:!cfip!
if !cfip! NEQ aa goto :eof
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
