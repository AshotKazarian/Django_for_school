@echo off
chcp 65001 >nul
title ArtProject

echo ========================================
echo          STARTING ARTPROJECT
echo ========================================
echo.

echo Checking Python...
python --version
if errorlevel 1 (
    echo ERROR: Python not found!
    echo.
    echo Install Python: https://www.python.org/ftp/python/3.14.0/python-3.14.0-amd64.exe
    echo.
    echo IMPORTANT: Check "Add Python to PATH" during installation
    echo.
    pause
    exit /b 1
)

echo.
echo Checking virtual environment...
if exist "venv\Scripts\python.exe" (
    call venv\Scripts\activate.bat
) else (
    echo Creating virtual environment...
    python -m venv venv
    call venv\Scripts\activate.bat
)

echo.
echo Installing packages...
pip install -r requirements.txt

echo.
echo Applying migrations...
python manage.py migrate

echo.
echo Checking for admin user...
python -c "
from django.contrib.auth.models import User
if User.objects.filter(is_superuser=True).exists():
    print('Admin user exists')
else:
    print('CREATING ADMIN USER')
    print('========================================')
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Created: admin / admin123')
"

echo.
echo ========================================
echo          PROJECT READY
echo ========================================
echo.
echo WEBSITE: http://127.0.0.1:8000
echo.
echo ADMIN:   http://127.0.0.1:8000/admin
echo.
echo USER:    admin
echo PASS:    admin123
echo.
echo Stop with: CTRL+C
echo ========================================
echo.

python manage.py runserver

echo.
pause
