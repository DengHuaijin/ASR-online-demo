from django.shortcuts import render
from django.http import HttpResponse
import logging
logger = logging.getLogger(__name__)
# Create your views here.
def demo(request, context = None):

    return render(request, "demo/index.html", context)
