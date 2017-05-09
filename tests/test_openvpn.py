from unittest import TestCase
from openvpn_init import update_openvpn

class TestOpenvpn(TestCase):

    def test_base(self):
        result = update_openvpn('tests/files/rc.conf.txt')
        self.assertTrue('openvpn_enable="YES"' in result)
        self.assertTrue('openvpn_configfile="/openvpn/default.ovpn"' in result)
        self.assertTrue('openvpn_flags="--script-security 2"' in result)

    def test_already_set(self):
        result = update_openvpn('tests/files/rc.conf.openvpn.txt')
        self.assertTrue('openvpn_enable="YES"' in result)
        self.assertTrue('openvpn_configfile="/openvpn/default.ovpn"' in result)
        self.assertTrue('openvpn_flags="--script-security 2"' in result)

    def test_commented1(self):
        result = update_openvpn('tests/files/rc.conf.openvpn2.txt')
        print(result)
        self.assertTrue('openvpn_enable="YES"' in result)
        self.assertTrue('openvpn_configfile="/openvpn/default.ovpn"' in result)
        self.assertTrue('openvpn_flags="--script-security 2"' in result)
