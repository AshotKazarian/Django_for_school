@echo off
chcp 65001 >nul
title ArtProject

echo ========================================
echo          STARTING ARTPROJECT
echo ========================================
echo.

echo [1/7] Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found!
    echo.
    echo Install Python: https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)
echo OK

echo.
echo [2/7] Activating virtual environment...
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    echo OK
) else (
    echo WARNING: venv not found, using system Python
)

echo.
echo [3/7] Installing packages...
pip install --quiet -r requirements.txt 2>nul
if errorlevel 1 (
    echo WARNING: Could not install from requirements.txt
    pip install --quiet django pillow 2>nul
)
echo OK

echo.
echo [4/7] Applying migrations...
python manage.py migrate --noinput 2>nul
echo OK

echo.
echo [5/7] Checking admin user...
python -c "
try:
    from django.contrib.auth.models import User
    if User.objects.filter(is_superuser=True).exists():
        print('OK - Admin exists')
    else:
        User.objects.create_superuser('admin', '', 'admin123')
        print('OK - Created admin/admin123')
except Exception as e:
    print('WARNING: ' + str(e))
" 2>nul

echo.
echo [6/7] Creating needed folders...
if not exist "media" mkdir media
if not exist "media\works" mkdir media\works

echo.
echo ========================================
echo          READY TO START
echo ========================================
echo WEBSITE:  http://127.0.0.1:8000
echo ADMIN:    http://127.0.0.1:8000/admin
echo USER:     admin
echo PASS:     admin123
echo.
echo Press any key to start server...
echo ========================================
pause >nul

echo.
echo [7/7] Starting server...
echo Press CTRL+C to stop
echo ========================================
python manage.py runserver

echo.
echo Server stopped
pause
