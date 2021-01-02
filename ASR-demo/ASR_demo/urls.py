"""
Definition of urls for ASR_demo.
"""

from django.conf.urls import include, url

import demo.views
import demo.form

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = [
    # Examples:
    # url(r'^$', ASR_demo.views.home, name='home'),
    # url(r'^ASR_demo/', include('ASR_demo.ASR_demo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
    url(r"^$", demo.views.demo, name = "demo"),
    url(r"^upload/$", demo.form.upload_file, name = "form")
]
