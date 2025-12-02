@echo off
REM Script para corrigir ClassNotFoundException
REM Execute este arquivo no PowerShell como Administrator

echo ============================================
echo CORRIGINDO CLASSNOTFOUND EXCEPTION
echo ============================================
echo.

REM 1. Deletar arquivo antigo do MainActivity
echo [1/5] Deletando MainActivity antigo...
if exist "android\app\src\main\kotlin\com\example\condogaiaapp\MainActivity.kt" (
    del "android\app\src\main\kotlin\com\example\condogaiaapp\MainActivity.kt"
    echo   ✓ Deletado: com/example/condogaiaapp/MainActivity.kt
) else (
    echo   ✓ Arquivo já não existe
)

REM 2. Deletar pasta vazia
echo.
echo [2/5] Limpando pastas vazias...
if exist "android\app\src\main\kotlin\com\example\condogaiaapp" (
    rmdir /s /q "android\app\src\main\kotlin\com\example\condogaiaapp"
    echo   ✓ Deletado: com/example/condogaiaapp/
) else (
    echo   ✓ Pasta já não existe
)

if exist "android\app\src\main\kotlin\com\example" (
    rmdir /s /q "android\app\src\main\kotlin\com\example"
    echo   ✓ Deletado: com/example/
) else (
    echo   ✓ Pasta já não existe
)

if exist "android\app\src\main\kotlin\com" (
    rmdir /s /q "android\app\src\main\kotlin\com"
    echo   ✓ Deletado: com/
) else (
    echo   ✓ Pasta já não existe
)

REM 3. Verificar novo MainActivity
echo.
echo [3/5] Verificando novo MainActivity...
if exist "android\app\src\main\kotlin\br\com\condogaia\MainActivity.kt" (
    echo   ✓ Encontrado: br/com/condogaia/MainActivity.kt
) else (
    echo   ✗ ERRO: br/com/condogaia/MainActivity.kt não encontrado!
    exit /b 1
)

REM 4. Flutter clean
echo.
echo [4/5] Executando: flutter clean...
call flutter clean
if %errorlevel% neq 0 (
    echo   ✗ Erro ao executar flutter clean
    exit /b 1
)
echo   ✓ Flutter clean concluído

REM 5. Flutter pub get
echo.
echo [5/5] Executando: flutter pub get...
call flutter pub get
if %errorlevel% neq 0 (
    echo   ✗ Erro ao executar flutter pub get
    exit /b 1
)
echo   ✓ Flutter pub get concluído

echo.
echo ============================================
echo ✓ CORRECÃO CONCLUÍDA COM SUCESSO!
echo ============================================
echo.
echo Próximo passo:
echo   flutter build appbundle --release
echo.
pause
