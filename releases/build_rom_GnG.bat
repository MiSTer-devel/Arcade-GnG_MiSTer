@echo off

set    zip=gng.zip
set ifiles=gg3.bin+gg4.bin+gg5.bin+gg1.bin+gg2.bin+gg9.bin+gg8.bin+gg7.bin+gg6.bin+gg11.bin+gg10.bin+gg11.bin+gg10.bin+gg17.bin+gg16.bin+gg15.bin+gg15.bin+gg14.bin+gg13.bin+gg12.bin+gg12.bin
set  ofile=a.gng.rom

rem alternative rom set:
rem set ifiles=mmt03d.8n+mmt04d.10n+mmt05d.13n+mm01.11e+mm02.14h+mm09.3c+mm08.1c+mm07.3b+mm06.1b+mm11.3e+mm10.1e+mm11.3e+mm10.1e+mm17.4n+mm16.3n+mm15.1n+mm15.1n+mm14.4l+mm13.3l+mm12.1l+mm12.1l
rem set    zip=gngt.zip


rem =====================================
setlocal ENABLEDELAYEDEXPANSION

set pwd=%~dp0
echo.
echo.

if EXIST %zip% (

	!pwd!7za x -otmp %zip%
	if !ERRORLEVEL! EQU 0 ( 
		cd tmp

		copy /b/y %ifiles% !pwd!%ofile%
		if !ERRORLEVEL! EQU 0 ( 
			echo.
			echo ** done **
			echo.
			echo Copy "%ofile%" into root of SD card
		)
		cd !pwd!
		rmdir /s /q tmp
	)

) else (

	echo Error: Cannot find "%zip%" file
	echo.
	echo Put "%zip%", "7za.exe" and "%~nx0" into the same directory
)

echo.
echo.
pause

rem        'rom8n'     :'mmt03d.8n',
rem        'rom10n'    :'mmt04d.10n',
rem        'rom12n'    :'mmt05d.13n',
rem        'rom_char'  :'mm01.11e',
rem        'audio'     :'mm02.14h',
rem
rem        'romx9'     :'mm09.3c',
rem        'romx8'     :'mm08.1c',
rem        'romx7'     :'mm07.3b',
rem        'romx6'     :'mm06.1b',
rem
rem        'romx11'    :'mm11.3e',
rem        'romx10'    :'mm10.1e',
rem        'romx11'    :'mm11.3e',
rem        'romx10'    :'mm10.1e',
rem
rem        'romx17'    :'mm17.4n',
rem        'romx16'    :'mm16.3n',
rem        'romx15'    :'mm15.1n',
rem        'romx15'    :'mm15.1n',
rem
rem        'romx14'    :'mm14.4l',
rem        'romx13'    :'mm13.3l',
rem        'romx12'    :'mm12.1l' 
rem        'romx12'    :'mm12.1l'

