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
echo 4. MIGRATIONS - This may take a moment...
python manage.py migrate

if errorlevel 1 (
    echo ERROR in migrations!
    echo.
    echo Trying to fix database...
    del db.sqlite3 2>nul
    python manage.py migrate
)

echo.
echo 5. Creating admin user...
python manage.py shell -c "from django.contrib.auth.models import User; User.objects.create_superuser('admin', '', 'admin123') if not User.objects.filter(username='admin').exists() else print('Admin exists')"

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
echo.

python manage.py runserver
pause
