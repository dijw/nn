@echo off
chcp 1251 >nul
setlocal enabledelayedexpansion

if not exist "gta_sa.exe" (
    echo Ошибка: gta_sa.exe не найден в текущей папке.
    echo Пожалуйста, запустите скрипт из корневой папки игры GTA San Andreas.
    pause
    exit /b
)

echo gta_sa.exe найден.
echo.
echo Выберите режим установки:
echo   1 - Установить только moonloader (ПОДХОДИТ ДЛЯ ЛАУНЧЕРА И SAMP КЛИЕНТА)
echo   2 - Полная установка с заменой всех файлов (ТОЛЬКО ДЛЯ SAMP КЛИЕНТА)
echo.
set /p "CHOICE=Введите номер (1 или 2): "

if "%CHOICE%"=="1" (
    set "MODE=moonloader_only"
    echo Выбран режим: установка только moonloader.
) else if "%CHOICE%"=="2" (
    set "MODE=full"
    echo Выбран режим: полная установка с заменой всех файлов.
) else (
    echo Неверный выбор. Завершение.
    pause
    exit /b
)

echo.

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

set "SEVENSTD="
for %%A in (
    "%ProgramFiles%\7-Zip-Zstandard\7z.exe"
    "%ProgramFiles(x86)%\7-Zip-Zstandard\7z.exe"
    "7z.exe"
) do (
    if exist %%~A (
        set "SEVENSTD=%%~A"
        goto :USE_7ZIPSTD
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
echo - 7-Zip: https://www.7zip.org/
echo - WinRAR: https://www.rarlab.com/
pause
exit /b

:USE_7ZIP
echo Найден 7-Zip: !SEVENZIP!
if "!MODE!"=="moonloader_only" (
    echo Извлекаем только папку moonloader...
    "!SEVENZIP!" x "%ZIP_FILE%" moonloader\* -aoa -y >nul
) else (
    echo Извлекаем все файлы с заменой...
    "!SEVENZIP!" x "%ZIP_FILE%" -aoa -y >nul
)
if %errorlevel% neq 0 (
    echo Ошибка при распаковке через 7-Zip.
    pause
    exit /b
)
goto :CLEANUP

:USE_7ZIPSTD
echo Найден 7-Zip ZStandard: !SEVENSTD!
if "!MODE!"=="moonloader_only" (
    echo Извлекаем только папку moonloader...
    "!SEVENSTD!" x "%ZIP_FILE%" moonloader\* -aoa -y >nul
) else (
    echo Извлекаем все файлы с заменой...
    "!SEVENSTD!" x "%ZIP_FILE%" -aoa -y >nul
)
if %errorlevel% neq 0 (
    echo Ошибка при распаковке через 7-Zip ZStandard.
    pause
    exit /b
)
goto :CLEANUP

:USE_WINRAR
echo Найден WinRAR: !WINRAR!
if "!MODE!"=="moonloader_only" (
    echo Извлекаем только папку moonloader...
    "!WINRAR!" x -aoa -inul -ibck -y "%ZIP_FILE%" moonloader\*
) else (
    echo Извлекаем все файлы с заменой...
    "!WINRAR!" x -aoa -inul -ibck -y "%ZIP_FILE%"
)
if %errorlevel% neq 0 (
    echo Ошибка при распаковке через WinRAR.
    pause
    exit /b
)
goto :CLEANUP

:CLEANUP
echo Удаляем архив...
del "%ZIP_FILE%"

set "TARGET_DIR=%~dp0moonloader"
echo Подготовка папки %TARGET_DIR%
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
)

echo Скачиваем helper.luac...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/dijw/nn-helper/raw/refs/heads/main/helper.luac' -OutFile '%TARGET_DIR%\helper.luac' -UseBasicParsing"

if exist "%TARGET_DIR%\helper.luac" (
    echo helper.luac успешно загружен в папку moonloader.
) else (
    echo Ошибка при загрузке helper.luac
    pause
    exit /b
)

echo.
echo Готово!
pause
exit /b