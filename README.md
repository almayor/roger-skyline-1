# roger-skyline-1

*This project is part of the official curriculum at [School 42](https://en.wikipedia.org/wiki/42_(school)).*

## Overview


* [Official instructions](resources/ft_printf.en.pdf)
* The goal of this project is to learn and practice key system and networking administration skills

## Set-up

This project includes a fully functional [Ansible playbook](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html) for automatic deployment of a web server. However, before it can be run, you should set up a minimal server. My steps were as follows: 

1. download Debian 10 (Buster) OS .iso
2. install it on a hyper-visor
	* CLI only
	* 1024 MB memory
	* disk size of 8 GB
	* separate `/` (2.0 GB), `/var` (1.0 GB), `/tmp` (256.9 MB), `/home` (4.2 GB) partitions
	* `ext4` as the primary file system
3. choose names
	* hostname `server`
	* domain name `rs1`
	* user `root` with password `toor`
	* user `user` with password `resu`
4. choose software to install during installation
	* SSH server
	* basic system utilities
5. configure network
	* set up a NAT and a Host-only network interfaces via the hypervisor
	* configure the NAT interface using DHCP and Host-only interface as static
	* my parameters were (as specified in `/etc/network/interfaces`)

```
# The loopback network interface
auto lo
iface lo inet loopback
```
```
# The NAT interface
allow-hotplug enp0s3
iface enp0s3 inet dhcp
```
```
# The Host-only network interface
allow-hotplug enp0s8
iface enp0s8 inet static
	address 192.168.56.2/30
```
6. edit `/etc/ssh/sshd-config` to change default SSH port to 2222
7. install `sudo` with `apt` and add `user` to `sudo` group

```
su -
apt install sudo
usermod -aG sudo user
```
## Deployment
To deploy using [Ansible](https://www.ansible.com), do

1. install Ansible with Homebrew or your preferred package manager

```
brew install ansible
```
2. run Ansible playbook and enter `resu` (`user`'s password required for `sudo`) when prompted

```
ansible-playbook -i ansible/hosts ansible/rs1.yml --ask-pass --ask-become-pass
```

Ansible will

1. *SSH*
	* disable root login
	* disable password authentication
	* add the RSA key from `assets/rs1-ssh.pub` to `~/.ssh/authorized_keys`
2. *ufw (firewall)*
	* install [`ufw`](https://wiki.debian.org/Uncomplicated%20Firewall%20%28ufw%29) using `apt` and enable it
	* disable IPv6
	* deny incoming, allow outgong connections by default
	* allow connections to SSH, HTTP and HTTPS ports
	* allow connections to port 19999 from `localhost` only (necessary for Netdata later on)
2. *sendmail (email server)*
	* install [`sendmail`](https://tecadmin.net/install-sendmail-on-debian-9-stretch/) using `apt`
3. *fail2ban (DOS protection)*
	* install [`fail2ban`](https://en.wikipedia.org/wiki/Fail2ban) using `apt` and enable it
	* create a new jail for generalized HTTP attacks via `GET`
	* enable jails for HTTP and SSH attacks
	* configure banaction to ban attackers' IP addresses via `iptabes` and send an email (via Sendmail) to my `@student.21-school.ru` mailbox.
	* ignore host IP address
4. *portsentry (port scan protection)*
	* install [`portsentry`](https://manpages.debian.org/testing/portsentry/portsentry.8.en.html) using `apt` and enable it
	* change operation mode to `audp` and `utcp` for advanced scan detection
	* configure to block IP's performing port scans via UDP and TCP
	* set up kill route via iptables
	* display port banner to attackers
	* ignore host IP address
5. *cron*
	* create a script that updates all the sources of package, then your packages and which logs the whole in a file named `/var/log/update_script.log`
	* create a scheduled task for this script once a week at 4AM and every time the machine reboots.
	* create a script to monitor changes of the /etc/crontab file and sends an email to root if it has been modified.
	* create a scheduled script task every day at midnight.
6. *netdata (real-time performance monitoring)*
	* download and install [Netdata](https://www.netdata.cloud)
7. *apache2 (web server)*
	* install [`apache2`](https://httpd.apache.org) using `apt` and enable it
	* configure a virtual host as a proxy to the netdata server
	* enable connections via HTTP and HTTPS (using `assets/rs1-ssl-selfsigned.crt` and `rs1-ssl.key`)
8. *stopped unused services* –– optional
	* stop `keyboard_setup.service` and `console_setup.service` (unnecessary if the server is only accessed via ssh)

## Useful links
* https://codeby.net/threads/kak-nastroit-fail2ban-dlja-zaschity-servera-apache-http.70077/
* https://www.garron.me/en/go2linux/fail2ban-protect-web-server-http-dos-attack.html
* https://technicalramblings.com/blog/how-to-add-email-notifications-to-fail2ban/
* https://www.opennet.ru/docs/RUS/portsentry/portsentry4.html
* https://www.computersecuritystudent.com/UNIX/UBUNTU/1204/lesson14/index.html
* https://github.com/KseniiaPrytkova/roger-skyline-1
* https://github.com/acuD1/roger-skyline-1


