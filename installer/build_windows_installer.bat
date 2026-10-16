@echo off
setlocal enabledelayedexpansion

echo =================================================================
echo           FARMSYS ECUADOR - COMPILADOR DE INSTALADOR WINDOWS
echo =================================================================
echo.

echo [1/3] Descargando y verificando dependencias de Flutter...
call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Fallo al ejecutar flutter pub get.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/3] Compilando ejecutable de produccion con ofuscacion de codigo...
call flutter build windows --release --obfuscate --split-debug-info=build\windows\debug-info
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Fallo la compilacion de Flutter para Windows.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2.5/3] Incluyendo librerias de tiempo de ejecucion Microsoft Visual C++...
set "RELEASE_DIR=build\windows\x64\runner\Release"
for %%D in (vcruntime140.dll vcruntime140_1.dll msvcp140.dll msvcp140_1.dll msvcp140_2.dll msvcp140_codecvt_ids.dll) do (
    if exist "%WINDIR%\System32\%%D" (
        copy /y "%WINDIR%\System32\%%D" "%RELEASE_DIR%\" >nul
        echo [OK] Incluida %%D
    )
)

echo.
echo [3/3] Generando instalador profesional con Inno Setup...
set "ISCC="
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set "ISCC=C:\Program Files\Inno Setup 6\ISCC.exe"
) else (
    where ISCC.exe >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        set "ISCC=ISCC.exe"
    ) else (
        echo [AVISO] Inno Setup no esta instalado o no se encuentra en el PATH.
        echo Puedes descargar Inno Setup gratis desde: https://jrsoftware.org/isdl.php
        echo O abrir manualmente el archivo installer\farmsys_windows_setup.iss en Inno Setup Compiler.
        pause
        exit /b 1
    )
)

"%ISCC%" "installer\farmsys_windows_setup.iss"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Fallo la creacion del instalador con Inno Setup.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo =================================================================
echo   EXITO: Instalador creado en installer\output\FarmSys_Setup_v1.0.0.exe
echo =================================================================
echo.
pause

