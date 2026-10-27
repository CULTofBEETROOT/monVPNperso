
# Linux users (here Debian-based) - Self-Hosted VPN
Open Terminal and download from root or sudoer with :
```
sudo mkdir -p /root/scripts/
sudo wget -P /root/scripts/ "https://github.com/CULTofBEETROOT/monVPNperso/install_vpn_ON_vps.sh"
sudo wget -P /root/scripts/ "https://github.com/CULTofBEETROOT/monVPNperso/local4linux_inst_age.sh"
sudo wget -P /root/scripts/ "https://github.com/CULTofBEETROOT/monVPNperso/local4linux_age-decyptWGclients.sh"
chmod -x /root/scripts/local4linux_age-decyptWGclients.sh
chmod -x /root/scripts/local4linux_inst_age.sh
sudo bash  /root/scripts/local4linux_inst_age.sh
sudo wget -P /root/scripts/ "https://github.com/CULTofBEETROOT/monVPNperso/local4ssh_linux.sh"
chmod -x /root/scripts/local4ssh_linux.sh
sudo bash /root/scripts/local4ssh_linux.sh
cat /root/.ssh/vps4wireguard*.pub
```

#### INSTALL Debian TRIXIE ON YOUR VPS 
+ from the VPS controle pannel,

  and when allowed, pre-install your SSH public key -the last line in your terminal- via the (Web) Controle Pannel.

  (if you don't find where to install Debian Trixie read your email from the provider and/or login to your online account)


#### Once your vps is running, let us copy in the script that will install wireguard server: 

#### copy-paste into your terminal:
```
scp -i /root/.ssh/vps4wireguard*[!.pub] -P 22 /root/scripts/install_vpn_ON_vps.sh root@vpsIP:/root/
```

#### log-into the VPS 
whatever way is yours:
* if you have been able to preset your ssh public key, you probably know how to log in
* if you have not been able to preset your ssh public key, you certainly have to login with your preset (or emailed) root password

and run the script we just copied-in on the previous step:
1) You will be prompted for the letter y on loosing (you won't) your ssh connection
2) on the public IP address of your VPS (from your emails)
3) on a non-root new user passphrase of your choice (to remember because next time you log-in, you'll be loging in non-root mode)
4) when two lines have enabled and you face a freez, count 5 seconds and press Ctrl+C,
   (that's normal and is due to the network), 
5) at what stage you can quit the ssh connection with :
```
exit 
exit
```

#### copy paste into your terminal:
```
mkdir -p /home/$USER/WGclients
scp -i /root/.ssh/vps4wireguard*[!.pub] -P 61525 vpnadmin@vpsIP:/home/vpnadmin/*.age /home/$USER/Downloads/WGclients/ 
bash /root/scripts/local4linux_age-decyptWGclients.sh
```
#### open any /home/$USER/WGclients/clientXXX.png file, 
#### scan the QR code from your mobile's wireguard's app QR scanner, 
#### namely: 

* (google) Play Store : https://play.google.com/store/apps/details?id=com.wireguard.android&hl=en-US

* Apple Store : https://apps.apple.com/us/app/wireguard/id1441195209

* (no longer on F-droid because wireguard updates themselves from within their VPN tunnel and F-droid can't verify updates).

## CONGRATULITION! 
### Your mobile Phone's browsing and Data now stream from your VPS location.
#
