#!/usr/local/bin/python
import sys
import os
import django

from django.core.wsgi import get_wsgi_application

HERE = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.realpath(os.path.join(HERE, "..")))
sys.path.append('/usr/local/www/freenasUI')
sys.path.append('/usr/local/www/freenasUI/..')
os.environ['DJANGO_SETTINGS_MODULE'] = 'freenasUI.settings'
application = get_wsgi_application()
os.chdir('/usr/local/www/freenasUI')
#django.setup()

from jails.models import JailMountPoint

def run():
    print(sys.path)
    pts = JailMountPoint.objects.all()
    print(pts)
    

if __name__ == "__main__":
    run()

