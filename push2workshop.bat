@echo off

set WSID=106427033

echo Please Confirm. Is the version set correctly?

pause
"../../../bin/gmad" create -folder . -out packaged.gma
"../../../bin/gmpublish" update -addon packaged.gma -id %WSID%
del packaged.gma
pause