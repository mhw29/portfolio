from django.shortcuts import render

# Create your views here.
def project_index(request):
    return render(request, "project_index.html")