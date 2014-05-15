@Echo off
REM 
REM This batch will create folder in DD-MM-YYYY format
REM And move all ZIP files to it.
REM developed by Georgiy Sitnikov for PD-31 Telekom Deutschland GMBH 2014
REM 
REM !!! Backup script will not works on network drives if they are not mapped
REM as local drive. This means if you running script under following address
REM \\debnlwnasc0103.de.ad.tmo\TDEV131\PD31\PD31-Jourfix\_active_ it will not works!!!
REM

	rem Going to Topics to create ZIP of included Folders
cd Topics\

	rem ZIPing files, each in own archive
FOR %%i IN (*.*) DO "..\7z.exe" a "%%~ni.zip" "%%i"

	rem Compressing Dirictories with subdirectories
for /d %%X in (*) do "..\7z.exe" a "%%X.zip" "%%X\" -r

	rem ZIPing current JF.ppt
..\7z.exe a Current_PD31_JF.zip ..\Current_PD31_JF.ppt -ssw

	rem Going two dirs up
cd ..\..

	rem Creating dir name
Set CURRDATE=%TEMP%\CURRDATE.TMP
DATE /T > %CURRDATE%
TIME /T > %TIME%
Set PARSEARG="eol=; tokens=1,2,3,4* delims=/. "
For /F %PARSEARG% %%i in (%CURRDATE%) Do SET DDMMYYYY=%%k-%%j-%%i

	rem Display output
Echo New dir %DDMMYYYY% is created
ECHO ======== Log from %DDMMYYYY% %TIME%========>> _active_\log.log

	rem Creating and Changing to new dir
mkdir %DDMMYYYY% >> _active_\log.log

	rem Going to created folder
cd %DDMMYYYY%

	rem Move ALL files to new dir
copy ..\_active_\Topics\*.zip . >> ..\_active_\log.log
del ..\_active_\Topics\*.zip
Echo OK!
