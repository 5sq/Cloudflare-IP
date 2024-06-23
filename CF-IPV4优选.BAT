@echo off &chcp 936 >NUL & cd "%~dp0" &TITLE CF-IPV4优选
setlocal enabledelayedexpansion
set /a numN=%random%
set tph=%tmp%\%numN%\
if EXIST %tph% rd /s /q %tph%
mkdir %tph%
echo ==================================================================
type nul >%tph%ip.txt
rem IPs 自动生成CF IP 数 默认1024个
set IPs=1024
rem sl 下载速度下限 默认 20 MB/s
set sl=20
Call :dnsip
Call :getv4 %IPs%
echo ==================================================================
Call :N个IP %tph%ip.txt
echo 根据nslookup 查询到的CloudflareIP段自动生成CF IP  %countIP% 个
title 自动生成CF IP  %countIP% 个
echo ==================================================================
set tp=443
set /p tp=请输入测试端口(默认%tp%):
CloudflareST.exe -f "%tph%ip.txt" -tp %tp% -t 5 -tlr 0.2 -tl 300 -sl %sl% -dt 5 
echo ==================================================================
Call :meta3 result.csv
echo ==================================================================
rd /s /q %tph%
pause&goto :eof
pause&exit
==========================================================
:dnsip
Set CFname=www.cloudflare.com;dash.cloudflare.com;blog.cloudflare.com;api.cloudflare.com
for %%a in (%CFname%) do (
Call :nslookupIP %%a&&set /a n+=1&&echo !n!、 nslookup 查询到的 %%a IP段 !ip12!.0.1/16
set ipd=!ipd!,!ip12!
)
goto :eof

:nslookupIP
for /f "tokens=1,2 delims=. skip=5" %%a in ('nslookup %1') do (
set str=%%a.%%b
set ip12=!str:~-6!
)
goto :eof

:getv4
for %%i in (%ipd%) do (
set !random!_%%i=randomsort
)
for /f "tokens=2,3,4 delims=_.=" %%i in ('set ^| findstr =randomsort ^| sort /m 10240') do (
call :randomcidrv4
if not defined %%i.%%j.!cidr! set %%i.%%j.!cidr!=anycastip&set /a n+=1&TITLE 自动生成CF-IPV4 !n! 个IP
if !n! EQU %1 goto getip
)
goto getv4

:randomcidrv4
set /a cidr=%random%%%256
set /a r=%random%%%256
set cidr=!cidr!.!r!
goto :eof

:getip
for /f "tokens=1 delims==" %%i in ('set ^| findstr =anycastip') do (
echo %%i>>%tph%ip.txt
)
goto :eof

:meta3
for /f "tokens=1 delims=, skip=1" %%i in (%1) do (set cfip=%%i&&goto :next)
:next
echo !cfip! CF节点连接测试回应：
curl --resolve www.cloudflare.com:443:!cfip! https://www.cloudflare.com/cdn-cgi/trace
goto :eof

:N个IP
set countIP=0
for /f "delims=" %%a in (%1) do (set /a countIP+=1)
goto :eof


Cloudflare 公开的所有 IP 段：https://www.cloudflare.com/zh-cn/ips/
同时以 IPv4 文本列表的形式提供：https://www.cloudflare.com/ips-v4
同时以 IPv6 文本列表的形式提供：https://www.cloudflare.com/ips-v6/#


