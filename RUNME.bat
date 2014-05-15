REM RUNME 2.3
REM for NSN RuleSet 4.0
REM Copyright by Georgiy Sitnikov
@echo off
cls
REM Check if file exist
if NOT EXIST %1 (
echo Input file not found
GOTO EOF)
REM Start working
set value=.clean
echo STEP 1 - Converting CSV to XML
echo  Input file name is: %1
echo  Output file name is: %1.xml
echo.
echo  ===HINT: It works slowly on Network drives===
echo.
echo  WORKING...
echo.
REM Here start NSN conversion tool. In case new version change
REM csv2rs_4.0.jar to actual file name. Check syntax if updated.
java -classpath csv2rs_4.1.jar com.nsn.pcrf.Csv2Xml %1 %1.xml
echo.
echo  DONE!
echo.
echo STEP 2 - Cleanup
echo  WORKING...
echo 	1. Deleting all unnecessary spaces after comma
REM Here start replacing script
type %1.xml|repl ", " "," >%1.xml%value%.step1
echo 	2. Replacing $ by ;
type %1.xml%value%.step1|repl "$" ";" L >%1.xml%value%.step2
echo  DONE!
echo.
echo  Cleanup
del %1.xml
del %1.xml%value%.step1
ren %1.xml%value%.step2 %1.xml
echo  Finished!
:EOF
