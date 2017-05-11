

.DEFAULT_GOAL := help
JAIL_HOST ?= test
FN_HOST ?= 192.168.1.229
FN_SETUP_DIR_NAME ?= fn9_setup
FN_USER_ME ?= mgering

.PHONY : clean portsnap openvpn clean_openvpn transmission transmission_dirs \
	clean-transmission jail

help:
	@echo Hi there

clean: clean_openvpn clean_transmission

###############
# FreeNAS 9 setup
###############

fn9_setup: copy_setup_to_f9 mount_setup

copy_setup_to_f9:
	-ssh $(FN_HOST) mkdir $(FN_SETUP_DIR_NAME)
	scp -r -p * $(FN_HOST):$(FN_SETUP_DIR_NAME)/

mount_setup: jail
	./in_host.py add_storage $(FN_HOST) $(JAIL_HOST) /mnt/vol1/home/$(FN_USER_ME)/$(FN_SETUP_DIR_NAME) /root/$(FN_SETUP_DIR_NAME)

jail:
	-./in_host.py create_jail $(FN_HOST) $(JAIL_HOST)

###############
# Portsnap
###############

/var/db/portsnap:
	portsnap fetch

/usr/ports: /var/db/portsnap
	portsnap extract

portsnap: /usr/ports
	portsnap update

####################
# openvpn rules
####################

/usr/local/etc/openvpn:
	mkdir -p /usr/local/etc/openvpn

/usr/local/etc/rc.d/openvpn: /usr/local/etc/rc.d
	pkg install -y openvpn
	./in_jail.py add_openvpn_rc_conf

/openvpn:
	mkdir -p /openvpn
	chown media:media /openvpn

openvpn: /openvpn /usr/local/etc/openvpn /usr/local/etc/rc.d/openvpn 
	@echo openvpn installed

clean_openvpn:
	-service openvpn stop
	-pkg remove -y openvpn
	rm -fr /openvpn
	./in_jail.py remove_openvpn_rc_conf


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
	./in_jail.py remove_transmission_rc_conf


##########################

FORCE:

test:
	-service asdfasdf stop
	service transmission stop
