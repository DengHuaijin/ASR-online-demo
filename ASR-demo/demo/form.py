import os
import sys
import time
import logging
from datetime import datetime
logger = logging.getLogger(__name__)
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

class UploadFileForm(forms.Form):
    title = forms.CharField(max_length=50)
    file = forms.FileField()

def handle_uploaded_file(f, filename):
    file_path = os.path.join(settings.MEDIA_ROOT, filename)
    with open(file_path, 'wb') as destination:
        for chunk in f.chunks():
            destination.write(chunk)
    return file_path

@csrf_exempt
def upload_file(request):
    if request.method == "POST":
        curtime = datetime.today().strftime("%Y-%m-%d-%H-%M-%S")
        form = UploadFileForm(request.POST, request.FILES)
        audio_file = handle_uploaded_file(request.FILES['audiofile'], "upload/" + curtime+".wav")
        text = tasks.recognition_ds2(audio_file)
        # text = "This it's the online speech recognition demo"
        # text = tasks.recognition_e2e(audio_file)
        context = {"text": text}
        response = views.demo(request, context)
        return response
    else:
        return HttpResponse(request.method)

@csrf_exempt
def record_file(request):
    if request.method == "POST":
        language = request.POST["language"]
        curtime = datetime.today().strftime("%Y-%m-%d-%H-%M-%S")
        if language == "en":
            audio_file = handle_uploaded_file(request.FILES['audio'], "record/" + curtime+".wav")
            # text = "English online speech recognition demo"
            text = tasks.recognition_ds2(audio_file)
        elif language == "jp":
            audio_file = handle_uploaded_file(request.FILES['audio'], "kaldi/kaldiAudio.wav")
            text = tasks.recognition_kaldi()
            # text = "Japanese online speech recognition demo"
        else:
            text = "recognition failed"
        context = {"text": text}
        return JsonResponse(context)
    else:
        return HttpResponse(request.method)
