import re

def update_or_add(contents, regex, replacement):
    p = re.compile(regex, re.MULTILINE)
    (contents, matches) = p.subn(replacement, contents)
    if matches == 0:
        contents += "\n"+replacement
    return contents

def update_or_add_setting(contents, name, value):
    regex = r'^#?\s*'+name+r'\s*=.*$'
    replacement = name+'='+value
    return update_or_add(contents, regex, replacement)

def update_or_add_settings(contents, settings):
    for (name, value) in settings:
        contents = update_or_add_setting(contents, name, value)
    return contents
