rem Needs ffmpeg!

@echo off
setlocal EnableDelayedExpansion
set base_name="rick"
set n=1
FOR %%G IN (*.wav) DO call :DoStuff %%G

:DoStuff
ren %1 %1.mp3
ffmpeg -i %1.mp3 out/%base_name%%n%.wav
del %1.mp3
set /A n+=1
:End