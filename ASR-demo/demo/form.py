import os
from django.shortcuts import render
from django.http import HttpResponseRedirect, HttpResponse
from django import forms
from ASR_demo import settings

class UploadFileForm(forms.Form):
    title = forms.CharField(max_length=50)
    file = forms.FileField()

def handle_uploaded_file(f):
    file_path = os.path.join(settings.MEDIA_ROOT, "uploadAudio")
    with open(file_path, 'wb') as destination:
        for chunk in f.chunks():
            destination.write(chunk)

def upload_file(request):
    if request.method == "POST":
        form = UploadFileForm(request.POST, request.FILES)
        # if form.is_valid():
        handle_uploaded_file(request.FILES['audiofile'])
        return HttpResponseRedirect("/demo/")
    else:
        return HttpResponse(request.method) 
    return HttpResponse("OK")

def search_upload(request):

    if request.method == "POST":
        file = request.FILES.get("file")
        file_path = os.path.join(settings.MEDIA_ROOT, "uploadFile")
        f = open(file_path, "wb")
        for chunk in file.chunks():
            f.write(chunk)
        f.close()
        return HttpResponse("OK")
    else:
        return HttpResponse(request.is_ajax())

def search_audio(request):
    audio = request.FILES.get("audio")
    file_path = os.path.join(settings.BASE_DIR, "wavfile")
    f = open(file_path, "wb")
    for chunk in f:
        audio.write(chunk)
    return HttpResponse("OK")
