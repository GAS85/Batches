@echo off
rem cls
echo Amdocs Timestamp and Versioning Tool Version 3.3.

REM Call help and version
if "%1" == "/h" (
	< RUNME.bat findrepl.bat "^<about>" /E:"^</about>" /O:+1:-1
	goto EOF
	)
if "%1" == "/v" goto EOF

REM some checks if all tools are on thear place
if NOT EXIST 7z.exe (
	echo Error! 7z.exe not found.
	goto :EOF)
if NOT EXIST 7z.dll (
	echo Error! 7z.dll not found.
	goto :EOF)
if NOT EXIST 7-zip.dll (
	echo Error! 7-zip.dll not found.
	goto :EOF)
if NOT EXIST findrepl.bat (
	echo Error! FindRepl.bat not found.
	echo Please check http://www.dostips.com/forum/viewtopic.php?f=3&t=4697
	goto :EOF)

REM Creating temp
mkdir %CD%\TMP > nul
set TEMPORARY=%CD%\TMP

REM check Start options
if "%1" == "/noh" (
	call :noHeader
	goto end
	) ELSE (
	goto start)
<about>

Copyright by Georgiy Sitnikov.

This tool will replace "#version: xxxx" with entered value.
For all files in current Dir and Sub Dirs, except LOCATION_ZONE, MCC and SGSN IP Mappers.
It will also add current date to "#date:" field in dd.mm.yyyy format.
It will create an archive with filenames based on config IDD specifications.
It will do backup of current statement in zip archive (can be replaced).

Files must have a proper Header in following format:
Line 1. Listed options, like: PEPProfile;Role...
Line 2. #version: xxxx <-- will be replaced.
Line 3. #date: xx.xx.xxxx <-- will be replaced.
Line 4. #change: Here some comment <-- will be replaced.
Line 5. #coms: Here some comment, will not be replaced.
Line 6. Here is the information part, no changes will be performed.

Follwing syntax can be used:

runme [] [/h] [/noh]

	[]	 you can use no parameter to run this programm in this case it works as discribed.
	/noh	 "no header" is option to not change header of the files, only follwoing numbers
		 will be updated in *Map.csv's files. No backup archive will be created.
	/h	 this help.
	/v	 version of the prgramm.
		 
Example: runme /noh
will update only follwoing numbers in all *Map.csv files

Example: runme
will update all headers and *Map.csv files numbering.

</about>

:start
REM Enter version to write into the files
echo Please enter new configuration Files version.
echo This value will be applied to all files in Sub Directories.
echo Usual format is X.XXX, e.g. 0.75a.
echo.
set /P AmdocsVersion=Please enter here:
echo.
echo You may also save some comment to your changes in this version, or just live it blank.
echo.
set /P AmdocsChange=Please enter here:
echo.
echo Now working...
echo.

REM Creating backup archive
7z.exe a "backup_pre_%AmdocsVersion%.zip" "*.csv" -r > nul

REM Creating Date Stamp to write into the files and file names
Set CURRDATE=%TEMPORARY%\CURRDATE.TMP
DATE /T > %CURRDATE%
Set PARSEARG="eol=; tokens=1,2,3,4* delims=/. "
For /F %PARSEARG% %%i in (%CURRDATE%) Do SET DOTS=%%i.%%j.%%k
For /F %PARSEARG% %%i in (%CURRDATE%) Do SET Date=%%i%%j%%k

REM Creating Time Stamp to write into the file names
set TIME=%TEMPORARY%\CURRTIME.TMP
TIME /T > %TIME%
Set PARSEARG="eol=; tokens=1,2,3,4* delims=/: "
for /F %PARSEARG% %%i in (%TIME%) Do SET hhmm=%%i%%j

REM %dots% Saves date with dots as delimiter
REM %date% Saves date with no delimiters
REM %hhmm% Saves current time in hhmm format

REM Creating TMP Directory for archive
mkdir %TEMPORARY%\%Date%_%hhmm%_%AmdocsVersion% > nul
mkdir %TEMPORARY%\%Date%_%hhmm%_%AmdocsVersion%\Mapper > nul

REM Storing old header of files
	set AmVERSION=%TEMPORARY%\version.TMP
	set AmDATE=%TEMPORARY%\date.TMP
	REM Following if a file to check old version and date in header. If file not exist replace with existing one.
	set CSV=PCEF_ServTempl.csv
	type %CSV%|FindRepl "#version" > %AmVERSION%
	type %CSV%|FindRepl "#date" > %AmDATE%
	
REM Storing Amdocs Old version to replace in AmOldVERSIONonly and date in AmOldDATEonly
	Set PARSEARG="eol=; tokens=1,2,3,4* delims= "
	For /F %PARSEARG% %%i in (%AmVERSION%) Do SET AmOldVERSIONonly=%%j
	For /F %PARSEARG% %%i in (%AmDATE%) Do SET AmOldDATEonly=%%j

REM find and replace all versions, dates and comments
FOR /R %%i IN (*.csv) DO (
	REM Creating a header
	setlocal enabledelayedexpansion
	set "fname=%%~ni"
	REM This is an exception list files LOCATION_ZONE_MAPPER, MCCMNC_MAPPER, SGSN_IP_MAPPER have no header.
	REM Pleas update this if needed. To add exception just write if "!fname!"=="!fname:NEW_EXCEPTION=!" at the end before "("
	if "!fname!"=="!fname:LOCATION=!" if "!fname!"=="!fname:MCCMNC=!" if "!fname!"=="!fname:SGSN_IP_MAPPER=!" (
		type %%i|FindRepl /O:1:1 >> %TEMPORARY%\%%~ni.csv.step1
		echo #version: %AmdocsVersion% >> %TEMPORARY%\%%~ni.csv.step1
		echo #date: %DOTS% >> %TEMPORARY%\%%~ni.csv.step1
		echo #change: %AmdocsChange% >> %TEMPORARY%\%%~ni.csv.step1
		echo #coms:  >> %TEMPORARY%\%%~ni.csv.step1
		type %TEMPORARY%\%%~ni.csv.step1 > %TEMPORARY%\%%~ni.csv.step3
		type %%i|FindRepl /O:6:10000 >> %TEMPORARY%\%%~ni.csv.step3
			
		REM This will added your versions and comment to the end of Versionierung file
		If "%%~ni" == "Versionierung" echo %AmdocsVersion%;%AmdocsChange% >> %TEMPORARY%\%%~ni.csv.step3
		
		move /Y "%TEMPORARY%\%%~ni.csv.step3" "%%i" > nul
		del %TEMPORARY%\%%~ni.csv.step* > nul
		echo  Finished for %%~ni
		echo.)
	endlocal
)
call :noHeader

Echo Copy and zipping files with correct filename Format:
FOR %%i IN (*.csv) DO (
REM will update PCEF_ServTempl with current information
	If "%%~ni" == "PCEF_ServTempl" (
		type %%i|FindRepl "..............%AmOldVERSIONonly%.csv" "%Date%_%hhmm%_%AmdocsVersion%.csv" /R >> %TEMPORARY%\%Date%_%hhmm%_%AmdocsVersion%\%%~ni_%Date%_%hhmm%_%AmdocsVersion%.csv
		type %%i|FindRepl "..............%AmOldVERSIONonly%.csv" "%Date%_%hhmm%_%AmdocsVersion%.csv" /R > %%i
		echo %%~ni_%Date%_%hhmm%_%AmdocsVersion%.csv
		) ELSE (
REM will update other file names
		echo %%~ni_%Date%_%hhmm%_%AmdocsVersion%.csv
		copy /Y %%i "%TEMPORARY%\%Date%_%hhmm%_%AmdocsVersion%\%%~ni_%Date%_%hhmm%_%AmdocsVersion%.csv" > nul
	)
	)
copy /Y Mapper\*.csv "%TEMPORARY%\%Date%_%hhmm%_%AmdocsVersion%\Mapper\"> nul

REM Creating ZIP
7z.exe a "config_%Date%_%hhmm%_%AmdocsVersion%.zip" "%TEMPORARY%\%Date%_%hhmm%_%AmdocsVersion%\*.csv" -r > nul

goto end

:noHeader
REM IF *Mapper --> update the priority (following numbers) inside of the file
echo.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!! Please ignore JAVA Errors from here !!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo.
FOR /R %%i IN (*Map.csv) DO (
	setlocal enabledelayedexpansion
	set "fname=%%~ni"
REM This is an exception for GGSN_ChargingRuleMap.csv.
	if "!fname!"=="!fname:GGSN_ChargingRuleMap=!" (
		type %%~ni.csv|FindRepl /O:6:14 >> %TEMPORARY%\%%~ni.csv.step2
		type %%~ni.csv|FindRepl /O:15:104 >> %TEMPORARY%\%%~ni.csv.step3
		type %%~ni.csv|FindRepl /O:105:1004 >> %TEMPORARY%\%%~ni.csv.step4
		type %%~ni.csv|FindRepl /O:1005:10004 >> %TEMPORARY%\%%~ni.csv.step5
			type %TEMPORARY%\%%~ni.csv.step2|FindRepl "^.;" ";" > %TEMPORARY%\%%~ni.csv.step6
			type %TEMPORARY%\%%~ni.csv.step3|FindRepl "^..;" ";" >> %TEMPORARY%\%%~ni.csv.step6
			type %TEMPORARY%\%%~ni.csv.step4|FindRepl "^...;" ";" >> %TEMPORARY%\%%~ni.csv.step6
			type %TEMPORARY%\%%~ni.csv.step5|FindRepl "^....;" ";" >> %TEMPORARY%\%%~ni.csv.step6
				type %TEMPORARY%\%%~ni.csv.step6|FindRepl /N > %TEMPORARY%\%%~ni.csv.step2
				type %TEMPORARY%\%%~ni.csv.step2|FindRepl ":" "" > %TEMPORARY%\%%~ni.csv.step3
					type %%i|FindRepl /O:1:5 > %TEMPORARY%\%%~ni.csv.step1
					type %TEMPORARY%\%%~ni.csv.step3 >> %TEMPORARY%\%%~ni.csv.step1
					type %TEMPORARY%\%%~ni.csv.step1 > %TEMPORARY%\%%~ni.csv.step3
				move /Y "%TEMPORARY%\%%~ni.csv.step3" "%%i" > nul
				del %TEMPORARY%\%%~ni.csv.step* > nul
			echo Number update finished for %%~ni
			echo.
			)
		endlocal
)
exit /b 0

:end
REM TMP Cleanup
rmdir /S /Q "%TEMPORARY%" > nul
exit /b 0
:EOF
