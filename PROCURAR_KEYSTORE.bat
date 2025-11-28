@echo off
echo ============================================================
echo   BUSCA DE ARQUIVO: upload-keystore-condogaia.jks
echo ============================================================
echo.

setlocal enabledelayedexpansion

echo Procurando em Desktop...
dir "%USERPROFILE%\Desktop\*keystore*.jks" 2>nul

echo.
echo Procurando em Downloads...
dir "%USERPROFILE%\Downloads\*keystore*.jks" 2>nul

echo.
echo Procurando em Documentos...
dir "%USERPROFILE%\Documents\*keystore*.jks" 2>nul

echo.
echo Procurando em APPflutter...
dir "c:\Users\Alexsander\Desktop\Aplicativos\APPflutter\*keystore*.jks" 2>nul

echo.
echo Procurando em condogaiaapp...
dir "c:\Users\Alexsander\Desktop\Aplicativos\APPflutter\condogaiaapp\*keystore*.jks" 2>nul

echo.
echo Procurando por qualquer arquivo .jks em APPflutter...
dir "c:\Users\Alexsander\Desktop\Aplicativos\APPflutter\*.jks" /s 2>nul

echo.
echo ============================================================
echo Se encontrou o arquivo, anote o caminho COMPLETO
echo ============================================================
echo.
pause
