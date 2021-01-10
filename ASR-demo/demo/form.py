import os
import sys
import time
from django.shortcuts import redirect, render
from django.http import HttpResponseRedirect, HttpResponse
from django.http.response import JsonResponse
from django.urls import reverse
from django import forms
from django.views.decorators.csrf import csrf_exempt
from ASR_demo import settings
from . import views
# from celery import task
# from celery.result import AsyncResult
from . import tasks

sys.path.append(settings.ASR_ROOT)
# import recognize

class UploadFileForm(forms.Form):
    title = forms.CharField(max_length=50)
    file = forms.FileField()

def handle_uploaded_file(f, filename):
    file_path = os.path.join(settings.MEDIA_ROOT, filename)
    with open(file_path, 'wb') as destination:
        for chunk in f.chunks():
            print(chunk)
            destination.write(chunk)
    return file_path

@csrf_exempt
def upload_file(request):
    if request.method == "POST":
        form = UploadFileForm(request.POST, request.FILES)
        audio_file = handle_uploaded_file(request.FILES['audiofile'], "uploadAudio.wav")
        text = tasks.recognition(settings.MEDIA_ROOT, "upload")
        # text = "This it's the online speech recognition demo"
        context = {"text": text}
        response = views.demo(request, context)
        return response
    else:
        return HttpResponse(request.method) 

@csrf_exempt
def record_file(request):
    if request.method == "POST":
        audio_file = handle_uploaded_file(request.FILES['audio'], "recordAudio.wav")
        # text = tasks.recognition(settings.MEDIA_ROOT, "record")
        text = "This it's the online speech recognition demo"
        context = {"text": text}
        return JsonResponse(context)
    else:
        return HttpResponse(request.method) 

