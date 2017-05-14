from unittest import TestCase
from transmission_vpn_monitor import stop_transmission, update_transmission_bind_addr

class TestTransmisson(TestCase):
    def test_bind_update(self):
        result = update_transmission_bind_addr('1.2.3.4', settings_file='tests/files/transmission-settings.json',
                                               try_stop_transmission=False)
        self.assertTrue(result)

    def test_stop_transmission(self):
        result = stop_transmission()
        self.assertFalse(result)

