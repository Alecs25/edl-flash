::  This is edl flash batch file for surabaya/colombo.
::  Make sure you phone can "adb reboot edl" to edl mode,
::  or enter edl mode by yourself.Enjoy your caffee time.

@echo off
set DIR_PATH=%cd%

set ADB_EXE=%DIR_PATH%\apps\adb.exe
set BUSYBOX_EXE=%DIR_PATH%\apps\busybox.exe
set FHLOADER_EXE=%DIR_PATH%\apps\fh_loader.exe
set SAHARA_EXE=%DIR_PATH%\apps\QSaharaServer.exe
set ENUMCOM_EXE=%DIR_PATH%\apps\enumcom.exe
set EMMCDL_EXE=%DIR_PATH%\apps\emmcdl.exe

%ADB_EXE% devices | %BUSYBOX_EXE% sed -n 2p | %BUSYBOX_EXE% grep device >nul
if "%ERRORLEVEL%"=="0" (
	%ADB_EXE% reboot edl
	%BUSYBOX_EXE% sleep 5
)

set LOOP_TIME=0
:LOOP
set COM_NUMBER=
for /f "delims=" %%i in ('%ENUMCOM_EXE% ^| %BUSYBOX_EXE% grep QCUSB ^| %BUSYBOX_EXE% awk {"print $2"}') do (set COM_NUMBER=%%i)
%BUSYBOX_EXE% echo %COM_NUMBER%

if "%COM_NUMBER%"=="" (
	%BUSYBOX_EXE% echo "wait for COM(9008)"
	%BUSYBOX_EXE% sleep 2

	set /a LOOP_TIME+=1
	if %LOOP_TIME%==30 (
		goto NODEVICE
	) else (
		goto LOOP
	)
)

%BUSYBOX_EXE% sleep 5

%EMMCDL_EXE% -p %COM_NUMBER% -f %~dp0\prog_emmc_firehose_8992_ddr.mbn -x rawprogram_unsparse.xml
%BUSYBOX_EXE% sleep 5
%EMMCDL_EXE% -p %COM_NUMBER% -f %~dp0\prog_emmc_firehose_8992_ddr.mbn -x patch0.xml
%BUSYBOX_EXE% sleep 3

pushd %TMP%
rem REST
%FHLOADER_EXE% --port=\\.\%COM_NUMBER% --noprompt --showpercentagecomplete --zlpawarehost=1 --memoryname=eMMC --reset
goto END
popd

:NODEVICE
echo ###################################
echo ######   No Device Found!!   ######
echo ###################################
echo.

pause
exit /b 1

:END
echo ###################################
echo ######  EDL Flash Done!!!  ########
echo ###################################
echo.

popd
pause
