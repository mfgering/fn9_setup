

.DEFAULT_GOAL := help

help:
	@echo Hi there

openvpn:
	pkg install openvpn bind-tools
	mkdir -p /usr/local/etc/openvpn
	mkdir -p /openvpn
	chown media:media /openvpn
	./openvpn_init.py
	@echo openvpn installed

test:
	./openvpn_init.py

