@echo off
chcp 65001 >nul
title ArtProject

echo ========================================
echo          STARTING ARTPROJECT
echo ========================================
echo.

echo 1. Checking Python...
python --version
if errorlevel 1 (
    echo ERROR: Python not found
    echo.
    echo Install Python 3.10-3.14 from: https://python.org
    pause
    exit /b 1
)

echo.
echo 2. Detecting Python version...
for /f "tokens=2" %%v in ('python --version 2^>^&1') do set pyver=%%v
echo Python %pyver%

REM Определяем папку с Pillow по версии
set PILLOW_FOLDER=pillow_py311
if "%pyver:~0,4%"=="3.10" set PILLOW_FOLDER=pillow_py310
if "%pyver:~0,4%"=="3.11" set PILLOW_FOLDER=pillow_py311
if "%pyver:~0,4%"=="3.12" set PILLOW_FOLDER=pillow_py312
if "%pyver:~0,4%"=="3.13" set PILLOW_FOLDER=pillow_py313
if "%pyver:~0,4%"=="3.14" set PILLOW_FOLDER=pillow_py314

REM Проверяем, существует ли папка с Pillow
if not exist "%PILLOW_FOLDER%" (
    echo.
    echo ========================================
    echo   ERROR: No Pillow for Python %pyver%
    echo ========================================
    echo.
    echo This project supports:
    echo   - Python 3.10
    echo   - Python 3.11
    echo   - Python 3.12
    echo   - Python 3.13
    echo   - Python 3.14
    echo.
    echo Your Python: %pyver%
    echo.
    pause
    exit /b 1
)

echo.
echo 3. Setting up Python path...
set PYTHONPATH=.\libs;.\%PILLOW_FOLDER%;%PYTHONPATH%
echo Using common libraries from: libs
echo Using Pillow from: %PILLOW_FOLDER%

echo.
echo 4. Testing libraries...
python -c "import PIL" 2>nul
if errorlevel 1 (
    echo ERROR: Cannot import PIL
    pause
    exit /b 1
)
echo PIL loaded successfully

python -c "import django" 2>nul
if errorlevel 1 (
    echo ERROR: Cannot import Django
    pause
    exit /b 1
)
echo Django loaded successfully

echo.
echo 5. Database setup...
python manage.py makemigrations gallery --noinput
python manage.py migrate --noinput

echo.
echo 6. Admin user check...
python manage.py shell -c "from django.contrib.auth.models import User; exit(0 if User.objects.filter(is_superuser=True).exists() else 1)" 2>nul
if errorlevel 1 (
    echo.
    echo ========================================
    echo   CREATING ADMIN USER
    echo ========================================
    python manage.py createsuperuser
)

echo.
echo ========================================
echo   STARTING SERVER
echo ========================================
echo Website: http://127.0.0.1:8000
echo Admin:   http://127.0.0.1:8000/admin
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

python manage.py runserver

echo.
echo ========================================
echo   Server stopped
echo ========================================
pause
