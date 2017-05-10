

.DEFAULT_GOAL := help

.PHONY : clean openvpn clean_openvpn transmission transmission_dirs clean-transmission

help:
	@echo Hi there

clean: clean_openvpn clean_transmission

####################
# openvpn rules
####################

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

clean_openvpn:
	-service openvpn stop
	-pkg remove -y openvpn
	rm -fr /openvpn


####################
# transmission rules
####################

transmission_dirs: /config /watched /downloads /incomplete-downloads

/config /watched /downloads /incomplete-downloads: FORCE
	mkdir -p $@
	chown media:media $@

/usr/local/etc/rc.d/transmission: /usr/local/etc/rc.d
	pkg install -y transmission-daemon transmission-cli transmission-web
	./in_jail.py add_transmission_rc_conf
	cp transmission-settings.json /config/settings.json
	touch /usr/local/etc/rc.d/transmission

transmission: transmission_dirs /usr/local/etc/rc.d/transmission
	-service transmission stop
	cp transmission-settings.json /config/settings.json

clean_transmission:
	-service transmission stop
	-pkg remove -y transmission-daemon transmission-cli transmission-web
	rm -fr /config /watched /downloads /incomplete-downloads
	-rmuser -y transmission


##########################

FORCE:

test:
	-service asdfasdf stop
	service transmission stop
