

.DEFAULT_GOAL := help
JAIL_HOST_TRANSMISSION ?= transmission2
JAIL_HOST_TRANSMISSION_IPV4 ?= DHCP
JAIL_HOST_SABNZBD ?= sabnzbd2
JAIL_HOST_SABNZBD_IPV4 ?= DHCP
JAIL_HOST_SONARR ?= sonarr2
JAIL_HOST_SONARR_IPV4 ?= DHCP
JAIL_HOST_RADARR ?= radarr2
JAIL_HOST_RADARR_IPV4 ?= DHCP
JAIL_HOST_JACKETT ?= jackett2
JAIL_HOST_JACKETT_IPV4 ?= DHCP
JACKETT_VERSION ?= v0.7.1422

FN_HOST ?= 192.168.1.221
#FN_HOST ?= 192.168.1.12
FN_SETUP_DIR_NAME ?= fn11_setup
FN_USER_ME ?= mgering

.PHONY : clean portsnap openvpn clean_openvpn transmission transmission_dirs \
	clean-transmission jail_sabnzbd update_root_ssh_key fn11_setup \
	copy_setup_to_fn11 mount_setup jail remote_sonarr_jail

###############################################################################
# Run these remotely
###############################################################################

#######################
# FreeNAS 11 setup
#######################

update_sabnzbd: copy_setup_to_fn11 mount_sabnzbd_setup remote_jail_sabnzbd_update

remote_jails: copy_setup_to_fn11 config_jails setup_jails

remote_setup: update_root_ssh_key enable_services copy_setup_to_fn11  create_groups create_users \
		import_vols update_cifs \
		update_home_dirs config_jails setup_jails setup_shares

update_root_ssh_key:
	-./in_host.py update_ssh_key $(FN_HOST) root id_rsa.pub

copy_setup_to_fn11:
	-ssh root@$(FN_HOST) mkdir $(FN_SETUP_DIR_NAME)
	scp -r -p * root@$(FN_HOST):$(FN_SETUP_DIR_NAME)/

alpha_to_test_app_files:
	scp -3 -r root@alpha:/mnt/vol1/apps/* root@$(FN_HOST):/mnt/vol1/apps/
	ssh root@$(FN_HOST) chown -R media:media /mnt/vol1/apps/*

create_groups:
	-./in_host.py add_group $(FN_HOST) 1000 mgering sudo
	-./in_host.py add_group $(FN_HOST) 1007 marsha no
	-./in_host.py add_group $(FN_HOST) 1008 meferree-backup no
	-./in_host.py add_group $(FN_HOST) 1009 lepton-backup no
	-./in_host.py add_group $(FN_HOST) 1010 mgering-dell-backup no
	-./in_host.py add_group $(FN_HOST) 1011 guest no

create_users:
	-./in_host.py add_user $(FN_HOST) mgering "Mike Gering" foo 1000 mgering sudo
	-./in_host.py add_user $(FN_HOST) marsha "Marsha Ferree" foo 1002 marsha no
	-./in_host.py add_user $(FN_HOST) meferree-backup "Backup for meferree laptop" foo 1008 meferree-backup no
	-./in_host.py add_user $(FN_HOST) lepton-backup "Backup for lepton" foo 1009 lepton-backup no
	-./in_host.py add_user $(FN_HOST) mgering-dell-bak "Backup for mgering" foo 1010 mgering-dell-backup no
	-./in_host.py add_user $(FN_HOST) guest "Guest" foo 1011 guest no


import_vols:
	./in_host.py import_volume $(FN_HOST) vol1
	./in_host.py import_volume $(FN_HOST) vol2

enable_services:
	./in_host.py enable_service $(FN_HOST) ssh
	./in_host.py enable_service $(FN_HOST) nfs
	./in_host.py enable_service $(FN_HOST) cifs

update_cifs:
	./in_host.py update_cifs $(FN_HOST)

update_home_dirs:
	$(info ******************************* Need to update home directories)

config_jails:
	./in_host.py config_jails $(FN_HOST) /mnt/vol1/jails

setup_jails: remote_transmission_jail remote_sonarr_jail remote_sabnzbd_jail remote_radarr_jail remote_jackett_jail

setup_shares: setup_smb_shares setup_nfs_shares

setup_smb_shares:
	-./in_host.py share_cifs_add $(FN_HOST) mgering /mnt/vol1/home/mgering guest_ok
	-./in_host.py share_cifs_add $(FN_HOST) downloads /mnt/vol1/media/downloads guest_ok
	-./in_host.py share_cifs_add $(FN_HOST) marsha /mnt/vol1/home/marsha guest_ok
	-./in_host.py share_cifs_add $(FN_HOST) meferree-backup /mnt/vol1/backups/meferree guest_ok
	-./in_host.py share_cifs_add $(FN_HOST) lepton-backup /mnt/vol1/backups/lepton/lepton-backups nope
	-./in_host.py share_cifs_add $(FN_HOST) media /mnt/vol1/media guest_ok
	-./in_host.py share_cifs_add $(FN_HOST) mgering-dell-backup /mnt/vol1/backups/mgering-dell nope
	-./in_host.py share_cifs_add $(FN_HOST) heap /mnt/vol1/heap guest_ok
	-./in_host.py share_cifs_add $(FN_HOST) software /mnt/vol1/software guest_ok

setup_nfs_shares:
	-./in_host.py share_nfs_add $(FN_HOST) /mnt/vol1/media media media

#############################################################################
# For each jail...
#############################################################################

remote_sabnzbd_jail: mount_sabnzbd_setup remote_jail_sabnzbd_services \
					 remote_jail_sabnzbd_storage

mount_sabnzbd_setup: jail_sabnzbd
	ssh root@$(FN_HOST) $(FN_SETUP_DIR_NAME)/fn11_host_make_mount.sh $(JAIL_HOST_SABNZBD) $(FN_SETUP_DIR_NAME)

remote_transmission_jail: mount_transmission_setup remote_jail_transmission_services \
					 remote_jail_transmission_storage remote_jail_openvpn_services \
					 remote_jail_openvpn_storage remote_jail_3proxy_services remote_jail_transvpnmon_services

mount_transmission_setup: jail_transmission
	ssh root@$(FN_HOST) $(FN_SETUP_DIR_NAME)/fn11_host_make_mount.sh $(JAIL_HOST_TRANSMISSION) $(FN_SETUP_DIR_NAME)

remote_sonarr_jail:  mount_sonarr_setup remote_jail_sonarr_services remote_jail_sonarr_storage

mount_sonarr_setup: jail_sonarr
	ssh root@$(FN_HOST) $(FN_SETUP_DIR_NAME)/fn11_host_make_mount.sh $(JAIL_HOST_SONARR) $(FN_SETUP_DIR_NAME)

remote_radarr_jail:  mount_radarr_setup remote_jail_radarr_services remote_jail_radarr_storage

mount_radarr_setup: jail_radarr
	ssh root@$(FN_HOST) $(FN_SETUP_DIR_NAME)/fn11_host_make_mount.sh $(JAIL_HOST_RADARR) $(FN_SETUP_DIR_NAME)

remote_jackett_jail:  mount_jackett_setup remote_jail_jackett_services remote_jail_jackett_storage

mount_jackett_setup: jail_jackett
	ssh root@$(FN_HOST) $(FN_SETUP_DIR_NAME)/fn11_host_make_mount.sh $(JAIL_HOST_JACKETT) $(FN_SETUP_DIR_NAME)

#############################################################################
# The sabnzbd jail
#############################################################################

jail_sabnzbd:
	-./in_host.py create_jail $(FN_HOST) $(JAIL_HOST_SABNZBD) $(JAIL_HOST_SABNZBD_IPV4)

remote_jail_sabnzbd_services:
	ssh root@$(FN_HOST) make -C $(FN_SETUP_DIR_NAME) fn11_jail_sabnzbd_services
	ssh root@$(FN_HOST) make -C $(FN_SETUP_DIR_NAME) fn11_sabnzbd_edit_ini

remote_jail_sabnzbd_update:
	ssh root@$(FN_HOST) make -C $(FN_SETUP_DIR_NAME) fn11_jail_sabnzbd_update

remote_jail_sabnzbd_storage:
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_SABNZBD) /mnt/vol1/apps/sabnzbd/config /sabnzbd/config
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_SABNZBD) /mnt/vol1/apps/sabnzbd/watched /sabnzbd/watched
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_SABNZBD) /mnt/vol1/apps/sabnzbd/incomplete-downloads /sabnzbd/incomplete-downloads
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_SABNZBD) /mnt/vol1/media/downloads /sabnzbd/downloads

#############################################################################
# The sonarr jail
#############################################################################

jail_sonarr:
	-./in_host.py create_jail $(FN_HOST) $(JAIL_HOST_SONARR) $(JAIL_HOST_SONARR_IPV4)

remote_jail_sonarr_services:
	ssh root@$(FN_HOST) make -C $(FN_SETUP_DIR_NAME) fn11_jail_sonarr_services

remote_jail_sonarr_storage:
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_SONARR) /mnt/vol1/apps/sonarr/config /sonarr/config
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_SONARR) /mnt/vol1/media/downloads /downloads
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_SONARR) /mnt/vol1/media/tv /tv
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_SONARR) /mnt/vol1/media/mfg/tv /mfg-tv
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_SONARR) /mnt/vol1/apps/sonarr/drone-factory /drone-factory
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_SONARR) /mnt/vol1/media/downloads /transmission/downloads
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_SONARR) /mnt/vol1/apps/sabnzbd/downloads /sabnzbd/downloads

#############################################################################
# The radarr jail
#############################################################################

jail_radarr:
	-./in_host.py create_jail $(FN_HOST) $(JAIL_HOST_RADARR) $(JAIL_HOST_RADARR_IPV4)

remote_jail_radarr_services:
	ssh root@$(FN_HOST) make -C $(FN_SETUP_DIR_NAME) fn11_jail_radarr_services

remote_jail_radarr_storage:
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_RADARR) /mnt/vol1/apps/radarr/config /radarr/config
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_RADARR) /mnt/vol1/media/downloads /downloads
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_RADARR) /mnt/vol1/media/movies /movies
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_RADARR) /mnt/vol1/media/mfg/movies /mfg-movies
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_RADARR) /mnt/vol1/apps/radarr/drone-factory /radarr/drone-factory
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_RADARR) /mnt/vol1/media/downloads /transmission/downloads
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_RADARR) /mnt/vol1/apps/sabnzbd/downloads /sabnzbd/downloads

#############################################################################
# The jackett jail
#############################################################################

jail_jackett:
	-./in_host.py create_jail $(FN_HOST) $(JAIL_HOST_JACKETT) $(JAIL_HOST_JACKETT_IPV4)

remote_jail_jackett_services:
	ssh root@$(FN_HOST) make -C $(FN_SETUP_DIR_NAME) fn11_jail_jackett_services

remote_jail_jackett_storage:
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_JACKETT) /mnt/vol1/apps/jackett/config /jackett/config
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_JACKETT) /mnt/vol1/apps/jackett/blackhole /jackett/blackhole

#############################################################################
# The transmission jail includes transmission, openvpn, and the proxy server
#############################################################################

jail_transmission:
	-./in_host.py create_jail $(FN_HOST) $(JAIL_HOST_TRANSMISSION) $(JAIL_HOST_TRANSMISSION_IPV4)

remote_jail_transmission_services:
	ssh root@$(FN_HOST) make -C $(FN_SETUP_DIR_NAME) fn11_jail_transmission_services fn11_transmission_settings

remote_jail_transmission_storage:
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_TRANSMISSION) /mnt/vol1/apps/transmission/config /transmission/config
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_TRANSMISSION) /mnt/vol1/media/downloads /transmission/downloads
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_TRANSMISSION) /mnt/vol1/apps/transmission/incomplete-downloads /transmission/incomplete-downloads
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_TRANSMISSION) /mnt/vol1/apps/transmission/watched /transmission/watched

remote_jail_transvpnmon_services:
	ssh root@$(FN_HOST) make -C $(FN_SETUP_DIR_NAME) fn11_jail_transvpnmon_services

remote_jail_openvpn_services:
	ssh root@$(FN_HOST) make -C $(FN_SETUP_DIR_NAME) fn11_jail_openvpn_services

remote_jail_3proxy_services:
	ssh root@$(FN_HOST) make -C $(FN_SETUP_DIR_NAME) fn11_jail_3proxy_services

remote_jail_openvpn_storage:
	-./in_host.py add_storage $(FN_HOST) $(JAIL_HOST_TRANSMISSION) /mnt/vol1/apps/openvpn /openvpn

###############################################################################
# Run these within the FreeNAS host
###############################################################################

fn11_jail_jackett_services: /mnt/vol1/apps/jackett/config /mnt/vol1/apps/jackett/blackhole
	jexec $(JAIL_HOST_JACKETT) make -C /root/$(FN_SETUP_DIR_NAME) jail_jackett_services

/mnt/vol1/apps/jackett/config:
	mkdir -p $@
	-mv /mnt/vol1/apps/jackett/Jackett @@
	-mv /mnt/vol1/apps/jackett/.mono @@
	chown -R media:media $@

/mnt/vol1/apps/jackett/blackhole:
	mkdir -p $@
	chown -R media:media $@

fn11_jail_radarr_services:
	jexec $(JAIL_HOST_RADARR) make -C /root/$(FN_SETUP_DIR_NAME) jail_radarr_services

fn11_jail_sabnzbd_services:
	jexec $(JAIL_HOST_SABNZBD) make -C /root/$(FN_SETUP_DIR_NAME) jail_sabnzbd_services

fn11_jail_sabnzbd_update:
	jexec $(JAIL_HOST_SABNZBD) /root/$(FN_SETUP_DIR_NAME)/update_sabnzbd.sh

fn11_jail_sonarr_services:
	jexec $(JAIL_HOST_SONARR) make -C /root/$(FN_SETUP_DIR_NAME) jail_sonarr_services

fn11_transmission_settings:
	#NOTE: The transmission daemon must be stopped before updating the settings
	jexec $(JAIL_HOST_TRANSMISSION) make -C /root/$(FN_SETUP_DIR_NAME) jail_transmission_settings
	sed -i '' -e "s/\s*\"download-dir\".*/\"download-dir\": \"transmission\/downloads\",/" /mnt/vol1/apps/transmission/config/settings.json
	sed -i '' -e "s/\s*\"incomplete-dir\".*/\"incomplete-dir\": \"transmission\/incomplete-downloads\",/" /mnt/vol1/apps/transmission/config/settings.json
	sed -i '' -e "s/\s*\"watch-dir\".*/\"watch-dir\": \"transmission\/watched\",/" /mnt/vol1/apps/transmission/config/settings.json

fn11_jail_transmission_services:
	jexec $(JAIL_HOST_TRANSMISSION) make -C /root/$(FN_SETUP_DIR_NAME) jail_transmission_services

#NOTE: The jail for openvpn is the transmission jail
fn11_jail_openvpn_services:
	jexec $(JAIL_HOST_TRANSMISSION) make -C /root/$(FN_SETUP_DIR_NAME) jail_openvpn_services

#NOTE: The jail for 3proxy is the transmission jail
fn11_jail_3proxy_services:
	jexec $(JAIL_HOST_TRANSMISSION) make -C /root/$(FN_SETUP_DIR_NAME) jail_3proxy_services

#NOTE: The jail for transvpnmon is the transmission jail
fn11_jail_transvpnmon_services:
	jexec $(JAIL_HOST_TRANSMISSION) make -C /root/$(FN_SETUP_DIR_NAME) jail_transvpnmon_services

fn11_sabnzbd_edit_ini:
	sed -i '' -e "s/\s*dirscan_dir.*/dirscan_dir = \/sabnzbd\/watched/" /mnt/vol1/apps/sabnzbd/config/sabnzbd.ini
	sed -i '' -e "s/\s*script_dir.*/script_dir = \/sabnzbd\/scripts/" /mnt/vol1/apps/sabnzbd/config/sabnzbd.ini
	sed -i '' -e "s/\s*complete_dir.*/complete_dir = \/sabnzbd\/downloads/" /mnt/vol1/apps/sabnzbd/config/sabnzbd.ini
	sed -i '' -e "s/\s*download_dir.*/download_dir = \/sabnzbd\/incomplete-downloads/" /mnt/vol1/apps/sabnzbd/config/sabnzbd.ini

###############################################################################
# Run these within the jail
###############################################################################

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
	./update_sabnzbd.sh

sabnzbd_update:
	./update_sabnzbd.sh

sabnzbd_dependencies:
	pkg install -y py27-sqlite3 unzip py27-yenc py27-cheetah py27-openssl py27-feedparser py27-utils unrar par2cmdline bash
	python2.7 -m ensurepip
	pip install sabyenc --upgrade

sabnzbd_config: /sabnzbd/config /sabnzbd/watched /sabnzbd/incomplete-downloads /sabnzbd/downloads /sabnzbd/scripts
	cp sabnzbd.rc.d /usr/local/etc/rc.d/sabnzbd
	./in_jail.py add_sabnzbd_rc_conf

/sabnzbd/config /sabnzbd/watched /sabnzbd/incomplete-downloads /sabnzbd/downloads /sabnzbd/scripts: FORCE
	mkdir -p $@
	chown media:media $@

jail_sabnzbd_services: sabnzbd_dependencies sabnzbd_source sabnzbd_config

####################
# transvpnmon rules
####################

jail_transvpnmon_services: /usr/local/etc/rc.d/transvpnmon /usr/sbin/transvpnmon.py

/usr/local/etc/rc.d/transvpnmon: ./transvpnmon
	cp ./transvpnmon /usr/local/etc/rc.d/transvpnmon
	./in_jail.py add_transvpnmon_rc_conf

/usr/sbin/transvpnmon.py: ./transvpnmon.py
	cp ./transvpnmon.py /usr/sbin/transvpnmon.py

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

jail_openvpn_services: /openvpn /usr/local/etc/openvpn /usr/local/etc/rc.d/openvpn
	@echo openvpn installed

clean_openvpn:
	-service openvpn stop
	-pkg remove -y openvpn
	rm -fr /openvpn
	./in_jail.py remove_openvpn_rc_conf


####################
# 3proxy rules
####################

/usr/local/etc/rc.d/3proxy: /usr/local/etc/rc.d
	pkg install -y 3proxy
	./in_jail.py add_3proxy_rc_conf

jail_3proxy_services: /usr/local/etc/rc.d/3proxy /usr/local/etc/3proxy.cfg /var/log/3proxy
	@echo 3proxy installed

/var/log/3proxy:
	-mkdir /var/log/3proxy

/usr/local/etc/3proxy.cfg: FORCE
	cp 3proxy.in /usr/local/etc/3proxy.cfg

clean_3proxy:
	-service 3proxy stop
	-pkg remove -y 3proxy
	./in_jail.py remove_3proxy_rc_conf


####################
# transmission rules
####################

jail_transmission_services: transmission_dirs /usr/local/etc/rc.d/transmission

transmission_dirs: /transmission/config /transmission/watched /transmission/downloads /transmission/incomplete-downloads

/transmission/config /transmission/watched /transmission/downloads /transmission/incomplete-downloads: FORCE
	mkdir -p $@
	chown media:media $@

/usr/local/etc/rc.d/transmission: /usr/local/etc/rc.d
	pkg install -y transmission-daemon transmission-cli transmission-web
	./in_jail.py add_transmission_rc_conf
	#cp transmission-settings.json /transmission/config/settings.json
	touch /usr/local/etc/rc.d/transmission

jail_transmission_settings:
	-service transmission stop
#NOTE: The settings file is updated outside the jail

clean_transmission:
	-service transmission stop
	-pkg remove -y transmission-daemon transmission-cli transmission-web
	rm -fr /transmission
	-rmuser -y transmission
	./in_jail.py remove_transmission_rc_conf

####################
# sonarr rules
####################

jail_sonarr_services: sonarr_dirs /usr/local/etc/rc.d/sonarr

sonarr_dirs: /sonarr/config /tv /downloads /drone-factory /mfg-tv /drone-factory /transmission/downloads /sabnzbd/downloads

/sonarr/config /tv /downloads /drone-factory /mfg-tv: FORCE
	mkdir -p $@
	chown media:media $@

/usr/local/etc/rc.d/sonarr: /usr/local/etc/rc.d
	pkg install -y sonarr
	./in_jail.py add_sonarr_rc_conf
	touch /usr/local/etc/rc.d/sonarr

clean_sonarr:
	-service sonarr stop
	-pkg remove -y sonarr
	rm -fr /sonarr
	./in_jail.py remove_sonarr_rc_conf

####################
# radarr rules
####################

jail_radarr_services: radarr_dirs /usr/local/etc/rc.d/radarr

radarr_dirs: /radarr/config /radarr/drone-factory /movies /downloads /mfg-movies /sabnzbd/downloads /transmission/downloads

#NOTE: The /downloads directory is already handled by the sonarr rule
/radarr/config /movies /mfg-movies /radarr/drone-factory: FORCE
	mkdir -p $@
	chown media:media $@

/usr/local/etc/rc.d/radarr: /usr/local/etc/rc.d
	pkg install -y radarr
	./in_jail.py add_radarr_rc_conf
	touch /usr/local/etc/rc.d/radarr

clean_radarr:
	-service radarr stop
	-pkg remove -y radarr
	rm -fr /radarr
	./in_jail.py remove_radarr_rc_conf


####################
# jackett rules
####################

jail_jackett_services: jackett_dirs jackett_source /usr/local/etc/rc.d/jackett

jackett_dirs: /jackett/config /jackett/blackhole

/jackett/config /jackett/blackhole: FORCE
	mkdir -p $@
	chown media:media $@

/usr/local/etc/rc.d/jackett:
	pkg update
	pkg upgrade -y
	pkg install -y lang/mono ftp/curl
	cp jacket.rc.d /usr/local/etc/rc.d/jackett
	./in_jail.py add_jackett_rc_conf

jackett_source:
	-mkdir /tmp/fn11_setup
	-rm -fr /tmp/fn11_setup/* /usr/local/share/jackett
	cd /tmp/fn11_setup; fetch https://github.com/Jackett/Jackett/releases/download/$(JACKETT_VERSION)/Jackett.Binaries.Mono.tar.gz; \
	  tar xzf *.gz; \
	  mv Jackett /usr/local/share/Jackett
	-rm -fr /tmp/fn11_setup

##########################

FORCE:

test:
	echo "TEST!!"
