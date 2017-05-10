from unittest import TestCase
from in_jail import _edit_transmission_rc_conf
from transmission_vpn_monitor import update_transmission_bind_addr

class TestTransmisson(TestCase):
    def test_bind_update(self):
        result = update_transmission_bind_addr('1.2.3.4', settings_file='tests/files/transmission-settings.json')
        self.assertTrue(result)

