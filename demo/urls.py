from django.conf.urls import url
from . import views

urlpatterns = [url(r"demo/", views.demo, name = "demo")]