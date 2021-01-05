import os,sys
from django.shortcuts import render
from django.http import HttpResponseRedirect, HttpResponse
from django import forms
from ASR_demo import settings

# sys.path.append(settings.ASR_ROOT)
# import recognize

class UploadFileForm(forms.Form):
    title = forms.CharField(max_length=50)
    file = forms.FileField()

def handle_uploaded_file(f, filename):
    file_path = os.path.join(settings.MEDIA_ROOT, filename)
    with open(file_path, 'wb') as destination:
        for chunk in f.chunks():
            destination.write(chunk)
    return file_path

def upload_file(request):
    if request.method == "POST":
        form = UploadFileForm(request.POST, request.FILES)
        audio_file = handle_uploaded_file(request.FILES['audiofile'], "uploadAudio.wav")
        text = "GGWP"
        # text = recognize.gen_words(audio_file)
        return render(request, "demo/index.html", {"text":text})
    else:
        return HttpResponse(request.method) 

def record_file(request):
    if request.method == "POST":
        form = UploadFileForm(request.POST, request.FILES)
        handle_uploaded_file(request.FILES['audio'], "recordAudio.wav")
        return HttpResponseRedirect("/demo/")
    else:
        return HttpResponse(request.method)

