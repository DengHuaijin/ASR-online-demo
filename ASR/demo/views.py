from django.shortcuts import render
from django.http import HttpResponse
from ASR import settings
import os

# Create your views here.

def demo(request):
    context = {}
    context["hello"] = "hello world"
    return render(request, "demo/index.html", context)

def search(request):
    audio = request.FILES.get("audio")
    file_path = os.path.join(settings.BASE_DIR, "wavfile")
    f = open(file_path, "wb")
    for chunk in f:
        f.write(chunk)
    return HttpResponse("OK")

