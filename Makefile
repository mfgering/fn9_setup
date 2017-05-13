

.DEFAULT_GOAL := help
JAIL_HOST ?= test3
FN_HOST ?= 192.168.1.229
FN_SETUP_DIR_NAME ?= fn9_setup
FN_USER_ME ?= mgering

.PHONY : clean portsnap openvpn clean_openvpn transmission transmission_dirs \
	clean-transmission jail_sabnzbd update_root_ssh_key fn9_setup \
	copy_setup_to_f9 mount_setup jail

help:
	@echo Hi there

clean: clean_openvpn clean_transmission

###############################################################################
# Run these remotely
###############################################################################

#######################
# FreeNAS 9 setup
#######################

remote_setup: update_root_ssh_key jail copy_setup_to_f9 mount_setup mount_setup

update_root_ssh_key:
	-./in_host.py update_ssh_key $(FN_HOST) root id_rsa.pub

copy_setup_to_f9:
	-ssh root@$(FN_HOST) mkdir $(FN_SETUP_DIR_NAME)
	scp -r -p * root@$(FN_HOST):$(FN_SETUP_DIR_NAME)/

mount_setup: jail
	ssh root@$(FN_HOST) $(FN_SETUP_DIR_NAME)/fn9_host_make_mount.sh $(JAIL_HOST) $(FN_SETUP_DIR_NAME)

jail:
	-./in_host.py create_jail $(FN_HOST) $(JAIL_HOST)

remote_jail_services:
	ssh root@$(FN_HOST) make -C $(FN_SETUP_DIR_NAME) fn9_jail_services

###############################################################################
# Run these within the FreeNAS host
###############################################################################

fn9_jail_services:
	jexec $(JAIL_HOST) make -C /root/$(FN_SETUP_DIR_NAME) jail_services

###############################################################################
# Run these within the jail
###############################################################################

jail_services: sabnzbd transmission openvpn

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
# sabnzbd
####################
sabnzbd_source:
	-mkdir /tmp/fn9_setup
	-rm -fr /tmp/fn9_setup/SABnzbd-2.0.0 /tmp/fn9_setup/sabnzbd /usr/local/share/sabnzbd
	cd /tmp/fn9_setup; fetch https://github.com/sabnzbd/sabnzbd/releases/download/2.0.0/SABnzbd-2.0.0-src.tar.gz; \
	  tar xzf SABnzbd-2.0.0-src.tar.gz; \
	  mv SABnzbd-2.0.0 sabnzbd; \
	  sed -i '' -e "s/#!\/usr\/bin\/python -OO/#!\/usr\/local\/bin\/python2.7 -OO/" sabnzbd/SABnzbd.py; \
	  mv sabnzbd /usr/local/share/

sabnzbd_packages:
	pkg install -y py27-sqlite3 unzip py27-yenc py27-cheetah py27-openssl py27-feedparser py27-utils unrar par2cmdline

sabnzbd_config: /sabnzbd_config
	cp sabnzbd.rc.d /usr/local/etc/rc.d/sabnzbd
	./in_jail.py add_sabnzbd_rc_conf

sabnzbd: sabnzbd_packages sabnzbd_source sabnzbd_config

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

transmission_dirs: /transmission_config /watched /downloads /incomplete-downloads

/transmission_config /watched /downloads /incomplete-downloads: FORCE
	mkdir -p $@
	chown media:media $@

/usr/local/etc/rc.d/transmission: /usr/local/etc/rc.d
	pkg install -y transmission-daemon transmission-cli transmission-web
	./in_jail.py add_transmission_rc_conf
	cp transmission-settings.json /transmission_config/settings.json
	touch /usr/local/etc/rc.d/transmission

transmission: transmission_dirs /usr/local/etc/rc.d/transmission
	-service transmission stop
	cp transmission-settings.json /transmission_config/settings.json

clean_transmission:
	-service transmission stop
	-pkg remove -y transmission-daemon transmission-cli transmission-web
	rm -fr /transmission_config /watched /downloads /incomplete-downloads
	-rmuser -y transmission
	./in_jail.py remove_transmission_rc_conf


##########################

FORCE:

test:
	echo "TEST!!"
