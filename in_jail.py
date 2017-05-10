#!/usr/local/bin/python2.7
import sys

def test(*args):
    return 42

if __name__ == '__main__':

    if len(sys.argv) > 1:
        f_name = sys.argv[1]
        fn_args = sys.argv[2:]
        result = getattr(sys.modules[__name__], f_name)(fn_args)
    else:
        print("No function argument.")