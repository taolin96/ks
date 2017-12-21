## Kickstar Command Section
# installation source http srv1
url --url=http://srv1.rhce.local//

# Use text install
text
skipx

# Keyboard layouts
keyboard us

# System language
lang en_NZ

# System timezone
timezone Pacific/Auckland --isUtc

# Root password
rootpw $1$ovOi7tGF$F.NIYAFig799K/4RNdGi.1 --iscrypted

# Set repo 
repo --name="RHEL7.2" --baseurl=http://srv1.rhce.local

selinux --enforcing
firewall --enabled --ssh

# System authorization information
auth --enableshadow --passalgo=sha512

# Partition clearing information
clearpart --all --initlabel

# Auto partitioning LVM only using sda
autopart --type=lvm
ignoredisk --only-use=sda

# custom partitioning
#part /boot --fstype=xfs --onpart=sda1 --size=512 --asprimary
#part pv.0 --fstype=lvmpv --ondisk=sda2 --size=6500
#volgroup system --pesize=4096 pv.0 
#logvol swap --vgname=system --name=swap --fstype=swap --size=1000

# System bootloader configuration
zerombr
bootloader --location=mbr --append="rhgb quiet crashkernel=auto" --boot-drive=sda

# Run the Setup Agent on first boot
firstboot --enable
reboot

# Network information
#network  --bootproto=dhcp --device=enp0s3 --onboot=off --ipv6=auto --no-activate

# Set hostname see Pre-installation script
%include /tmp/networkhost.txt

%addon com_redhat_kdump --enable --reserve-mb='auto'
%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

## Packages Section 
%packages
@base
@core
ipa-client
kexec-tools
%end

## Pre-installation Script
%pre
iotty=`tty`
exec < $iotty > $iotty 2> $iotty
echo -n "Enter the server hostname : "
read NAME
echo $NAME > /tmp/hostname.tmp
sleep 1
echo "network --hostname=$NAME.rhce.local" >> /tmp/networkhost.txt
%end

## Post-installation Script
%post
# Generate SSH keys to ensure that ipa-client-install uploads them to the IdM server
/usr/sbin/sshd-keygen
# Run the client install script
/usr/sbin/ipa-client-install --unattended --domain=RHCE.LOCAL --enable-dns-updates --mkhomedir -w Letmejoin --realm=RHCE.LOCAL --server=srv1.rhce.local
%end
