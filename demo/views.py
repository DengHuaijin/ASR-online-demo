from django.shortcuts import render

# Create your views here.

def demo(request):
    context = {}
    context["hello"] = "hello world"
    return render(request, "demo/index.html", context)

