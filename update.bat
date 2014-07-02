@echo off
echo Did you remember to set the version?
pause
"../../../bin/gmad" create -folder . -out packaged.gma
"../../../bin/gmpublish" update -addon packaged.gma -id 106427033
pause