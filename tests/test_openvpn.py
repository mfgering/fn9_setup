from unittest import TestCase
from in_jail import _edit_openvpn_rc_conf
from transmission_vpn_monitor import update_transmission_bind_addr

class TestOpenvpn(TestCase):

    def test_base(self):
        result = _edit_openvpn_rc_conf('tests/files/rc.conf.txt')
        self.assertTrue('openvpn_enable="YES"' in result)
        self.assertTrue('openvpn_configfile="/openvpn/default.ovpn"' in result)
        self.assertTrue('openvpn_flags="--script-security 2"' in result)

    def test_already_set(self):
        result = _edit_openvpn_rc_conf('tests/files/rc.conf.openvpn.txt')
        self.assertTrue('openvpn_enable="YES"' in result)
        self.assertTrue('openvpn_configfile="/openvpn/default.ovpn"' in result)
        self.assertTrue('openvpn_flags="--script-security 2"' in result)
        result = _edit_openvpn_rc_conf('tests/files/rc.conf.txt', write_file=False, add_conf=False)
        self.assertTrue('openvpn_enable' not in result)

    def test_commented1(self):
        result = _edit_openvpn_rc_conf('tests/files/rc.conf.openvpn2.txt')
        print(result)
        self.assertTrue('openvpn_enable="YES"' in result)
        self.assertTrue('openvpn_configfile="/openvpn/default.ovpn"' in result)
        self.assertTrue('openvpn_flags="--script-security 2"' in result)
