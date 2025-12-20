@echo off
chcp 65001 >nul
title ArtProject

echo ========================================
echo          ЗАПУСК ПРОЕКТА ARTPROJECT
echo ========================================
echo.

echo Проверка Python...
python --version
if errorlevel 1 (
    echo Установка Python: https://www.python.org/ftp/python/3.14.0/python-3.14.0-amd64.exe
    pause
    exit /b 1
)

echo.
echo Проверка виртуального окружения...
if not exist "venv\Scripts\python.exe" (
    echo Создание виртуального окружения...
    python -m venv venv
)

call venv\Scripts\activate.bat

pip install -r requirements.txt
python manage.py makemigrations gallery
python manage.py migrate

python manage.py shell -c "from django.contrib.auth.models import User; exit(0 if User.objects.filter(is_superuser=True).exists() else 1)"
if errorlevel 1 (
    echo.
    echo СОЗДАНИЕ АДМИНИСТРАТОРА
    echo ========================================
    python manage.py createsuperuser
)

echo.
echo ЗАПУСК
echo ========================================
echo.
echo САЙТ:  http://127.0.0.1:8000
echo.
echo АДМИН: http://127.0.0.1:8000/admin  
echo.
echo Ctrl+C = ОСТАНОВКА
echo ========================================
echo.

python manage.py runserver
pause
