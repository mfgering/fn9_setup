import re

def edit(contents, regex, replacement, add_conf):
    p = re.compile(regex, re.MULTILINE)
    (contents, matches) = p.subn(replacement, contents)
    if matches == 0 and add_conf:
        if not contents.endswith("\n"):
            contents += "\n"
        contents += replacement+"\n"
    return contents

def edit_setting(contents, name, value, add_conf):
    regex = r'^#?\s*'+name+r'\s*=.*$'
    replacement = name+'='+value if add_conf else ''
    return edit(contents, regex, replacement, add_conf)

def edit_rc_conf_settings(contents, settings, add_conf):
    for (name, value) in settings:
        contents = edit_setting(contents, name, value, add_conf)
    return contents
