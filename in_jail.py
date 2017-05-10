#!/usr/local/bin/python2.7
import sys

def test(*args):
    pass

if __name__ == '__main__':

    if len(sys.argv) > 1:
        f_name = sys.argv[1]
        fn_args = sys.argv[2:]
        x = getattr(sys.modules[__name__], f_name)(fn_args)
        pass
    else:
        print("No function argument.")