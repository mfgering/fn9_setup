AUTH_NAME = 'root'
AUTH_PASSWORD = 'bogus'

try:
    LOCAL_SETTINGS
except NameError:
    try:
        from local_settings import *
    except ImportError:
        pass