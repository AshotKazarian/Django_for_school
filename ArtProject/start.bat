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
    echo Install Python 3.8+ from: https://python.org
    echo IMPORTANT: Check "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

echo.
echo 2. Adding libraries to Python path...
set PYTHONPATH=.\libs;%PYTHONPATH%

echo.
echo 3. Database setup...
python manage.py makemigrations gallery --noinput 2>nul
python manage.py migrate --noinput

echo.
echo 4. Admin user check...
python manage.py shell -c "from django.contrib.auth.models import User; exit(0 if User.objects.filter(is_superuser=True).exists() else 1)"
if errorlevel 1 (
    echo CREATING ADMIN USER
    echo ========================================
    python manage.py createsuperuser
)

echo.
echo START
echo ========================================
echo WEBSITE: http://127.0.0.1:8000
echo ADMIN:   http://127.0.0.1:8000/admin  
echo Ctrl+C = STOP
echo ========================================

python manage.py runserver
pause
