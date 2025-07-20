@echo off
chcp 1251 >nul
setlocal enabledelayedexpansion

set "ZIP_URL=https://github.com/dijw/nn/raw/refs/heads/main/horassist.zip"
set "ZIP_FILE=horassist.zip"

echo Скачиваем архив...
powershell -Command "Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%ZIP_FILE%' -UseBasicParsing"

if not exist "%ZIP_FILE%" (
    echo Ошибка: архив не был скачан.
    pause
    exit /b
)

set "SEVENZIP="
for %%A in (
    "%ProgramFiles%\7-Zip\7z.exe"
    "%ProgramFiles(x86)%\7-Zip\7z.exe"
    "7z.exe"
) do (
    if exist %%~A (
        set "SEVENZIP=%%~A"
        goto :USE_7ZIP
    )
)

set "WINRAR="
for %%A in (
    "%ProgramFiles%\WinRAR\WinRAR.exe"
    "%ProgramFiles(x86)%\WinRAR\WinRAR.exe"
    "WinRAR.exe"
) do (
    if exist %%~A (
        set "WINRAR=%%~A"
        goto :USE_WINRAR
    )
)

echo Не удалось найти установленные архиваторы (7-Zip или WinRAR).
echo Пожалуйста, установите один из них:
echo - 7-Zip: https://www.7-zip.org/
echo - WinRAR: https://www.rarlab.com/
pause
exit /b

:USE_7ZIP
echo Найден 7-Zip: !SEVENZIP!
"!SEVENZIP!" x "%ZIP_FILE%" -y >nul
if %errorlevel% neq 0 (
    echo Ошибка при распаковке через 7-Zip.
    pause
    exit /b
)
goto :CLEANUP

:USE_WINRAR
echo Найден WinRAR: !WINRAR!
"!WINRAR!" x -inul -ibck -y "%ZIP_FILE%"
if %errorlevel% neq 0 (
    echo Ошибка при распаковке через WinRAR.
    pause
    exit /b
)
goto :CLEANUP

:CLEANUP
echo Удаляем архив...
del "%ZIP_FILE%"
echo Готово!
pause
exit /b
