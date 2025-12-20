@echo off
chcp 65001 > nul
title ArtProject

echo ========================================
echo           3anyck npoekta ARTPROJECT
echo ========================================
echo.

echo 1. Проверка Python...
python --version
if errorlevel 1 (
    echo ОШИБКА: Python не найден!
    echo.
    echo Установите Python сюда: https://www.python.org/downloads/
    echo.
    echo Важно: при установке отметьте [X] "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

echo.
echo 2. Активация виртуального окружения...
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo Виртуальное окружение не найдено. Создание...
    python -m venv venv
    call venv\Scripts\activate.bat
)

echo.
echo 3. Установка библиотек...
pip install -r requirements.txt

echo.
echo 4. Создание миграций и применение...
python manage.py makemigrations
python manage.py migrate

echo.
echo 5. Проверка и создание суперпользователя...
python -c "
from django.contrib.auth.models import User
if User.objects.filter(is_superuser=True).exists():
    print('Суперпользователь уже существует')
else:
    print('Создание суперпользователя...')
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Создан: логин=admin, пароль=admin123')
"

echo.
echo ========================================
echo          CTAPT
echo ========================================
echo.
echo САЙТ:  http://127.0.0.1:8000
echo АДМИН: http://127.0.0.1:8000/admin
echo.
echo Логин:    admin
echo Пароль:   admin123
echo.
echo Остановка: CTRL+C
echo ========================================
echo.

python manage.py runserver

echo.
pause
