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
2. *iptables*
	* drop invalid packets
	* prevent ICMP-based attacks
	* blacklist port scanners
	* blacklist spoofer
	* blacklist SSH bruteforce attackers
	* mitigate DOS attacks (HTTP(S), RST flood, SYN flood, ping-death)
2. *sendmail (email server)*
	* install [`sendmail`](https://tecadmin.net/install-sendmail-on-debian-9-stretch/) using `apt`
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
8. *unused_services* –– optional
	* stop `keyboard_setup.service` and `console_setup.service` (unnecessary if the server is only accessed via ssh)

## Useful links
* <https://codeby.net/threads/kak-nastroit-fail2ban-dlja-zaschity-servera-apache-http.70077/>
* <https://xakep.ru/2010/11/02/53653/>
* <https://serverfault.com/questions/410604/iptables-rules-to-counter-the-most-common-dos-attacks>
* <https://www.computersecuritystudent.com/UNIX/UBUNTU/1204/lesson14/index.html>
* <https://github.com/KseniiaPrytkova/roger-skyline-1>
* <https://github.com/acuD1/roger-skyline-1>


