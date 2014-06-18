@if (@X)==(@Y) @end /* Harmless hybrid line that begins a JScript comment

::************ Documentation ***********

:::  RUNME.bat Version 3.6
:::  for NSN RuleSet 4.1+
:::  Copyright by Georgiy Sitnikov
:::  This file will convert csv to xml and delete all unnecessary
:::  spaces, replease all $ to ;
:::
:::  RUNME.bat [Options or Input file]
:::
:::       /v - check version of the file
:::       /h - this help
:::       /a - work with current folder AND all subfolders
:::          - if nothing is set, prohramm will check all csv files in
:::            current folder and no subfolders
:::  Input file - input file can always be set, in this case only
:::            this file will be converted
:::
:::  About Java Portion:
:::  Search  - By default, this is a case sensitive JScript (ECMA) regular
:::            expression expressed as a string.
:::
:::            JScript regex syntax documentation is available at
:::            http://msdn.microsoft.com/en-us/library/ae5bf541(v=vs.80).aspx
:::
:::  Replace - By default, this is the string to be used as a replacement for
:::            each found search expression. Full support is provided for
:::            substituion patterns available to the JScript replace method.
:::
:::            For example, $& represents the portion of the source that matched
:::            the entire search pattern, $1 represents the first captured
:::            submatch, $2 the second captured submatch, etc. A $ literal
:::            can be escaped as $$.
:::
:::            An empty replacement string must be represented as "".
:::
:::            Replace substitution pattern syntax is fully documented at
:::            http://msdn.microsoft.com/en-US/library/efy6s3e6(v=vs.80).aspx

::************ Batch portion ***********
@echo off
	REM Here NSN conversion tool. In case new version, change
	REM "csv2rs_4.1.jar" to actual file name. Check syntax if updated.
set JAR=csv2RS_4.1.jar
if NOT EXIST %JAR% (
	echo.
	echo !!! ERROR, convertion tool is not found !!!
	echo Please copy %JAR% to current folder:
	echo %~dp0
	exit /b 1)
cls
	REM Check if file exist, if not will do operation for ALL CSVs in folder
if "%1" == "" (
	GOTO :CSVs
	exit /b 0)
if "%1" == "/v" (
	<"%~f0" cscript //E:JScript //nologo "%~f0" "^:::" "" a >%tmp%\help.file
	set /p TEXT=< %tmp%\help.file
	echo %TEXT%
	exit /b 0)
if "%1" == "/a" (
	GOTO :Recurs
	exit /b 0)
if "%1" == "/h" (
	<"%~f0" cscript //E:JScript //nologo "%~f0" "^:::" "" a
	exit /b 0)
if NOT EXIST %1 (
	echo Input file not found
	echo  ===HINT: It does not work on not mapped Network drives===
	exit /b 1)
GOTO :Normal

	REM Work on all CSVs in folder AND subfolders
:CSVs
FOR %%i IN (*.csv) DO (
	java -classpath %JAR% com.nsn.pcrf.Csv2Xml %%i %tmp%\%%~ni.xml
	echo  WORKING...
		REM Here start replacing script
	type %tmp%\%%~ni.xml|cscript //E:JScript //nologo "%~f0" ", " "," >%tmp%\%%~ni.xml.step1
	type %tmp%\%%~ni.xml.step1|cscript //E:JScript //nologo "%~f0" "$" ";" L >%tmp%\%%~ni.xml.step2
	move /Y "%tmp%\%%~ni.xml.step2" "%~dp0%%~ni.xml"
	del %tmp%\%%~ni.xml*
	echo  Finished for %%~ni
	echo.)
exit /b 0

:Recurs
FOR /R %%i IN (*.csv) DO (
	java -classpath %JAR% com.nsn.pcrf.Csv2Xml "%%i" %tmp%\%%~ni.xml
	echo  WORKING...
		REM Here start replacing script
	type %tmp%\%%~ni.xml|cscript //E:JScript //nologo "%~f0" ", " "," >%tmp%\%%~ni.xml.step1
	type %tmp%\%%~ni.xml.step1|cscript //E:JScript //nologo "%~f0" "$" ";" L >%tmp%\%%~ni.xml.step2
	move /Y "%tmp%\%%~ni.xml.step2" "%%i.xml"
	del %tmp%\%%~ni.xml*
	echo  Finished for %%~ni
	echo.)
exit /b 0

:Normal
	REM Start working for exact file
echo STEP 1 - Converting CSV to XML
echo  Input file name is: %1
echo  Output file name is: %1.xml
echo  ===HINT: It does not work on not mapped Network drives===
echo.
echo  Converting...
	REM CHECK SYNTAX HERE, IF UPDATED!!!
java -classpath %JAR% com.nsn.pcrf.Csv2Xml %1 %tmp%\%1.xml
echo.
echo  DONE!
echo.
echo STEP 2 - Cleanup
echo  WORKING...
echo 	1. Deleting all unnecessary spaces after comma
	REM Here start replacing script
type %tmp%\%1.xml|cscript //E:JScript //nologo "%~f0" ", " "," >%tmp%\%1.xml.step1
echo 	2. Replacing $ by ;
type %tmp%\%1.xml.step1|cscript //E:JScript //nologo "%~f0" "$" ";" L >%tmp%\%1.xml.step2
echo  DONE!
echo.
echo  STEP 3 - Cleanup temp files
move /Y "%tmp%\%1.xml.step2" "%~dp0%1.xml"
del %tmp%\%1.xml*
echo  Finished.
exit /b 0

************* JScript portion **********/
var env=WScript.CreateObject("WScript.Shell").Environment("Process");
var args=WScript.Arguments;
var search=args.Item(0);
var replace=args.Item(1);
var options="g";
if (args.length>2) options+=args.Item(2).toLowerCase();
var multi=(options.indexOf("m")>=0);
var alterations=(options.indexOf("a")>=0);
if (alterations) options=options.replace(/a/g,"");
var srcVar=(options.indexOf("s")>=0);
if (srcVar) options=options.replace(/s/g,"");
if (options.indexOf("v")>=0) {
  options=options.replace(/v/g,"");
  search=env(search);
  replace=env(replace);
}
if (options.indexOf("x")>=0) {
  options=options.replace(/x/g,"");
  replace=replace.replace(/\\\\/g,"\\B");
  replace=replace.replace(/\\q/g,"\"");
  replace=replace.replace(/\\x80/g,"\\u20AC");
  replace=replace.replace(/\\x82/g,"\\u201A");
  replace=replace.replace(/\\x83/g,"\\u0192");
  replace=replace.replace(/\\x84/g,"\\u201E");
  replace=replace.replace(/\\x85/g,"\\u2026");
  replace=replace.replace(/\\x86/g,"\\u2020");
  replace=replace.replace(/\\x87/g,"\\u2021");
  replace=replace.replace(/\\x88/g,"\\u02C6");
  replace=replace.replace(/\\x89/g,"\\u2030");
  replace=replace.replace(/\\x8[aA]/g,"\\u0160");
  replace=replace.replace(/\\x8[bB]/g,"\\u2039");
  replace=replace.replace(/\\x8[cC]/g,"\\u0152");
  replace=replace.replace(/\\x8[eE]/g,"\\u017D");
  replace=replace.replace(/\\x91/g,"\\u2018");
  replace=replace.replace(/\\x92/g,"\\u2019");
  replace=replace.replace(/\\x93/g,"\\u201C");
  replace=replace.replace(/\\x94/g,"\\u201D");
  replace=replace.replace(/\\x95/g,"\\u2022");
  replace=replace.replace(/\\x96/g,"\\u2013");
  replace=replace.replace(/\\x97/g,"\\u2014");
  replace=replace.replace(/\\x98/g,"\\u02DC");
  replace=replace.replace(/\\x99/g,"\\u2122");
  replace=replace.replace(/\\x9[aA]/g,"\\u0161");
  replace=replace.replace(/\\x9[bB]/g,"\\u203A");
  replace=replace.replace(/\\x9[cC]/g,"\\u0153");
  replace=replace.replace(/\\x9[dD]/g,"\\u009D");
  replace=replace.replace(/\\x9[eE]/g,"\\u017E");
  replace=replace.replace(/\\x9[fF]/g,"\\u0178");
  replace=replace.replace(/\\b/g,"\b");
  replace=replace.replace(/\\f/g,"\f");
  replace=replace.replace(/\\n/g,"\n");
  replace=replace.replace(/\\r/g,"\r");
  replace=replace.replace(/\\t/g,"\t");
  replace=replace.replace(/\\v/g,"\v");
  replace=replace.replace(/\\x[0-9a-fA-F]{2}|\\u[0-9a-fA-F]{4}/g,
    function($0,$1,$2){
      return String.fromCharCode(parseInt("0x"+$0.substring(2)));
    }
  );
  replace=replace.replace(/\\B/g,"\\");
  search=search.replace(/\\\\/g,"\\B");
  search=search.replace(/\\q/g,"\"");
  search=search.replace(/\\x80/g,"\\u20AC");
  search=search.replace(/\\x82/g,"\\u201A");
  search=search.replace(/\\x83/g,"\\u0192");
  search=search.replace(/\\x84/g,"\\u201E");
  search=search.replace(/\\x85/g,"\\u2026");
  search=search.replace(/\\x86/g,"\\u2020");
  search=search.replace(/\\x87/g,"\\u2021");
  search=search.replace(/\\x88/g,"\\u02C6");
  search=search.replace(/\\x89/g,"\\u2030");
  search=search.replace(/\\x8[aA]/g,"\\u0160");
  search=search.replace(/\\x8[bB]/g,"\\u2039");
  search=search.replace(/\\x8[cC]/g,"\\u0152");
  search=search.replace(/\\x8[eE]/g,"\\u017D");
  search=search.replace(/\\x91/g,"\\u2018");
  search=search.replace(/\\x92/g,"\\u2019");
  search=search.replace(/\\x93/g,"\\u201C");
  search=search.replace(/\\x94/g,"\\u201D");
  search=search.replace(/\\x95/g,"\\u2022");
  search=search.replace(/\\x96/g,"\\u2013");
  search=search.replace(/\\x97/g,"\\u2014");
  search=search.replace(/\\x98/g,"\\u02DC");
  search=search.replace(/\\x99/g,"\\u2122");
  search=search.replace(/\\x9[aA]/g,"\\u0161");
  search=search.replace(/\\x9[bB]/g,"\\u203A");
  search=search.replace(/\\x9[cC]/g,"\\u0153");
  search=search.replace(/\\x9[dD]/g,"\\u009D");
  search=search.replace(/\\x9[eE]/g,"\\u017E");
  search=search.replace(/\\x9[fF]/g,"\\u0178");
  if (options.indexOf("l")>=0) {
    search=search.replace(/\\b/g,"\b");
    search=search.replace(/\\f/g,"\f");
    search=search.replace(/\\n/g,"\n");
    search=search.replace(/\\r/g,"\r");
    search=search.replace(/\\t/g,"\t");
    search=search.replace(/\\v/g,"\v");
    search=search.replace(/\\x[0-9a-fA-F]{2}|\\u[0-9a-fA-F]{4}/g,
      function($0,$1,$2){
        return String.fromCharCode(parseInt("0x"+$0.substring(2)));
      }
    );
    search=search.replace(/\\B/g,"\\");
  } else search=search.replace(/\\B/g,"\\\\");
}
if (options.indexOf("l")>=0) {
  options=options.replace(/l/g,"");
  search=search.replace(/([.^$*+?()[{\\|])/g,"\\$1");
  replace=replace.replace(/\$/g,"$$$$");
}
if (options.indexOf("b")>=0) {
  options=options.replace(/b/g,"");
  search="^"+search
}
if (options.indexOf("e")>=0) {
  options=options.replace(/e/g,"");
  search=search+"$"
}
var search=new RegExp(search,options);
var str1, str2;

if (srcVar) {
  str1=env(args.Item(3));
  str2=str1.replace(search,replace);
  if (!alterations || str1!=str2) WScript.Stdout.WriteLine(str2);
} else {
  while (!WScript.StdIn.AtEndOfStream) {
    if (multi) {
      WScript.Stdout.Write(WScript.StdIn.ReadAll().replace(search,replace));
    } else {
      str1=WScript.StdIn.ReadLine();
      str2=str1.replace(search,replace);
      if (!alterations || str1!=str2) WScript.Stdout.WriteLine(str2);
    }
  }
}
