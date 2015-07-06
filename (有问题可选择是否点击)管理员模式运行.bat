rem FlashFlashPlayerTrust.cmd
@echo off
set  "mainDir=%cd%"
c:

cd %windir%\system32\Macromed

if not exist "Flash\FlashPlayerTrust" mkdir "Flash\FlashPlayerTrust '

cd .\Flash\FlashPlayerTrust

echo c:\ >DanmakuHelper.cfg

echo d:\ >>DanmakuHelper.cfg

echo e:\ >>DanmakuHelper.cfg

echo F:\ >>DanmakuHelper.cfg

echo G:\ >>DanmakuHelper.cfg

echo H:\ >>DanmakuHelper.cfg

echo %mainDir% >>DanmakuHelper.cfg

cd %userprofile%\Application Data\Macromedia\Flash Player\

if not exist "Flash Player\#Security\FlashPlayerTrust" mkdir "Flash Player\#Security\FlashPlayerTrust"

cd .\#Security\FlashPlayerTrust

echo c:\ >DanmakuHelper.cfg

echo d:\ >>DanmakuHelper.cfg

echo e:\ >>DanmakuHelper.cfg

echo F:\ >>DanmakuHelper.cfg

echo %mainDir% >>DanmakuHelper.cfg
