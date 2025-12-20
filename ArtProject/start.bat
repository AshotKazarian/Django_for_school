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
    pause
    exit /b 1
)

echo.
echo 2. Activating venv...
if exist "venv\Scripts\activate.bat" call venv\Scripts\activate.bat

echo.
echo 3. Installing packages...
pip install -r requirements.txt

echo.
echo 4. Applying ALL migrations...
python manage.py makemigrations
python manage.py migrate

echo.
echo 5. CHECKING FOR ADMIN USER...
python manage.py shell -c "from django.contrib.auth.models import User; exit(0 if User.objects.filter(is_superuser=True).exists() else 1)"
if errorlevel 1 (
    echo.
    echo ========================================
    echo    CREATE ADMIN ACCOUNT
    echo ========================================
    echo.
    echo You need to create an admin account.
    echo.
    echo Enter:
    echo   - Username
    echo   - Email (press Enter to skip)
    echo   - Password
    echo.
    python manage.py createsuperuser --username admin --email admin@school.ru --noinput
    python manage.py shell -c "
from django.contrib.auth.models import User
user = User.objects.get(username='admin')
user.set_password('admin123')
user.save()
print('Admin created: admin / admin123')
"
)

echo.
echo ========================================
echo          READY
echo ========================================
echo WEBSITE:  http://127.0.0.1:8000
echo ADMIN:    http://127.0.0.1:8000/admin
echo USER:     admin
echo PASS:     admin123
echo.
echo Press CTRL+C to stop
echo ========================================

python manage.py runserver
