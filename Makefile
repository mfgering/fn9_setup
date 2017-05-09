

.DEFAULT_GOAL := help

help:
	@echo Hi there

openvpn:
	pkg install -y openvpn bind-tools
	mkdir -p /usr/local/etc/openvpn
	mkdir -p /openvpn
	chown media:media /openvpn
	./openvpn_init.py
	@echo openvpn installed

transmission:
	-service transmission stop
	pkg install -y transmission-daemon transmission-cli transmission-web
	mkdir -p /config /watched /downloads /incomplete-downloads
	chown media:media /config /watched /downloads /incomplete-downloads
	cp transmission-settings.json /config/settings.json

test:
	-service asdfasdf stop
	service transmission stop
