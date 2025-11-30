@echo off
chcp 65001 >nul
title ArtProject

echo ========================================
echo          3anyck npoekta ARTPROJECT
echo ========================================
echo.

echo npoBepka Ha Python...
python --version
if errorlevel 1 (
    echo YctaHoBka Python: https://www.python.org/ftp/python/3.14.0/python-3.14.0-amd64.exe
    pause
    exit /b 1
)


pip install -r requirements.txt
python manage.py makemigrations
python manage.py migrate

python manage.py shell -c "from django.contrib.auth.models import User; exit(0 if User.objects.filter(is_superuser=True).exists() else 1)"
if errorlevel 1 (
    echo CREATING ADMIN USER
    echo ========================================
    python manage.py createsuperuser
)

echo.
echo CTAPT
echo ========================================
echo.
echo WEBSITE: http://127.0.0.1:8000
echo.
echo ADMIN:   http://127.0.0.1:8000/admin  
echo.
echo Ctrl+C = STOP
echo ========================================
echo.

python manage.py runserver
pause