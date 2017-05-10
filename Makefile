

.DEFAULT_GOAL := help

help:
	@echo Hi there

/usr/local/etc/openvpn:
	mkdir -p /usr/local/etc/openvpn

/usr/local/etc/rc.d/openvpn: /usr/local/etc/rc.d
	pkg install -y openvpn
	./openvpn_init.py

/openvpn:
	mkdir -p /openvpn
	chown media:media /openvpn

openvpn: /openvpn /usr/local/etc/openvpn /usr/local/etc/rc.d/openvpn 
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
