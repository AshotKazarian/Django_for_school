from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('login/', views.user_login, name='login'),
    path('register/', views.register, name='register'),
    path('logout/', views.user_logout, name='logout'),
    path('profile/', views.profile, name='profile'),
    path('profile/update/', views.profile_update, name='profile_update'),
    path('work/create/', views.work_create, name='work_create'),
    path('<str:username>/', views.user_profile, name='user_profile'),
    path('<str:username>/<int:work_id>/', views.work_detail, name='work_detail'),
    path('<str:username>/<int:work_id>/update/', views.work_update, name='work_update'),
]