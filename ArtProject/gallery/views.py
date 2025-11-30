from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.core.paginator import Paginator
from django.contrib.auth.models import User
from .models import Work, Profile
from .forms import UserRegisterForm, UserLoginForm, ProfileUpdateForm, WorkCreateForm

def get_or_create_profile(user):
    """Получить или создать профиль для пользователя"""
    try:
        return user.profile
    except Profile.DoesNotExist:
        return Profile.objects.create(user=user)

def home(request):
    """Главная страница - лента всех работ"""
    works_list = Work.objects.all().select_related('author', 'genre').prefetch_related('tools').order_by('-created_at')
    
    paginator = Paginator(works_list, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    return render(request, 'gallery/home.html', {
        'page_obj': page_obj,
        'works': page_obj.object_list
    })

def work_detail(request, username, work_id):
    """Детальная страница работы с указанием автора"""
    work = get_object_or_404(
        Work.objects.select_related('author', 'genre', 'proportion').prefetch_related('tools'), 
        id=work_id,
        author__username=username
    )
    is_owner = request.user == work.author
    return render(request, 'gallery/work_detail.html', {
        'work': work,
        'is_owner': is_owner
    })

@login_required
def work_update(request, username, work_id):
    """Редактирование работы"""
    work = get_object_or_404(Work, id=work_id, author__username=username)
    
    # Проверяем, что пользователь является автором работы
    if request.user != work.author:
        messages.error(request, 'Вы не можете редактировать чужую работу.')
        return redirect('work_detail', username=username, work_id=work_id)
    
    if request.method == 'POST':
        form = WorkCreateForm(request.POST, request.FILES, instance=work)
        if form.is_valid():
            updated_work = form.save()
            messages.success(request, 'Работа успешно обновлена!')
            return redirect('work_detail', username=username, work_id=work_id)
    else:
        form = WorkCreateForm(instance=work)
    
    return render(request, 'gallery/work_update.html', {
        'form': form,
        'work': work
    })

def user_profile(request, username):
    """Публичный профиль пользователя"""
    profile_user = get_object_or_404(User, username=username)
    works_list = Work.objects.filter(author=profile_user).order_by('-created_at')
    
    paginator = Paginator(works_list, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    return render(request, 'gallery/profile.html', {
        'profile_user': profile_user,
        'is_own_profile': request.user == profile_user,
        'page_obj': page_obj,
        'works': page_obj.object_list
    })

def register(request):
    """Страница регистрации"""
    if request.method == 'POST':
        form = UserRegisterForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, 'Регистрация прошла успешно!')
            return redirect('home')
    else:
        form = UserRegisterForm()
    
    return render(request, 'gallery/register.html', {'form': form})

def user_login(request):
    """Страница входа"""
    if request.method == 'POST':
        form = UserLoginForm(data=request.POST)
        if form.is_valid():
            user = form.get_user()
            login(request, user)
            messages.success(request, f'Добро пожаловать, {user.username}!')
            return redirect('home')
    else:
        form = UserLoginForm()
    
    return render(request, 'gallery/login.html', {'form': form})

@login_required
def user_logout(request):
    """Выход из системы"""
    logout(request)
    messages.success(request, 'Вы успешно вышли из системы.')
    return redirect('home')

@login_required
def profile(request):
    """Личный кабинет пользователя (редирект на публичный профиль)"""
    return redirect('user_profile', username=request.user.username)

@login_required
def profile_update(request):
    """Редактирование профиля"""
    # Получаем или создаем профиль для пользователя
    profile = get_or_create_profile(request.user)
    
    if request.method == 'POST':
        form = ProfileUpdateForm(request.POST, request.FILES, instance=profile)
        if form.is_valid():
            form.save()
            messages.success(request, 'Профиль успешно обновлен!')
            return redirect('profile')
    else:
        form = ProfileUpdateForm(instance=profile)
    
    return render(request, 'gallery/profile_update.html', {'form': form})

@login_required
def work_create(request):
    """Создание новой работы"""
    if request.method == 'POST':
        form = WorkCreateForm(request.POST, request.FILES)
        if form.is_valid():
            work = form.save(commit=False)
            work.author = request.user
            work.save()
            form.save_m2m()
            messages.success(request, 'Работа успешно добавлена!')
            return redirect('user_profile', username=request.user.username)
    else:
        form = WorkCreateForm()
    
    return render(request, 'gallery/work_create.html', {'form': form})