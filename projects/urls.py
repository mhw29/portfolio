from django.urls import path, include
from . import views

urlpatterns = [
    path("", views.project_index, name="project_index"),
]