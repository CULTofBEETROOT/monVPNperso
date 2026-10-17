# monVPNperso
all steps from 0 knowledge to 100% installed wireguard vpn, running, affordable, ...


#
## REQUIREMENTS: 
1 PC or 1 laptop, running either 
* Linux, or 
* Windows, or 
* MacOS (or derivative) ...
1 VPS (eg. flokinet.is or 1984.is or netcup.de, 's most basic and affordable VPS offer)

optional : your 100 most impatient friends with their mobile phones devices, in suspense watching you.
#


### for Windows users

Open PowerShell or Windows Terminal and install with WinGet:
```
winget install --id FiloSottile.age
```
Close and reopen the terminal, then check that it runs:
```
age --versionage-keygen --help
```

download and save in "$HOME\Desktop" the files from the urls :
```
https://github.com/CULTofBEETROOT/monVPNperso/local4windows_inst_age.ps1
https://github.com/CULTofBEETROOT/monVPNperso/local4ssh_windows.ps1
```
try to run this file :
```
cd "$HOME\Desktop"
.\local4windows_inst_age.ps1
.\local4ssh_windows.ps1
Get-Content "$HOME\.ssh\vps4wireguard*.pub"
```
IF!!! Windows blocks running scripts, allow it for this PowerShell window only, then run the script:
```
cd "$HOME\Desktop"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\local4windows_inst_age.ps1
.\local4ssh_windows.ps1
Get-Content "$HOME\.ssh\vps4wireguard*.pub"
```
#

### for macOS users

Open Terminal and install with Homebrew:
```
brew install age
```
Check the installation:
```
age --versionage-keygen --help
```
Download the script from this url and save the file in "$HOME/Desktop":

```
https://github.com/CULTofBEETROOT/monVPNperso/local4macOs_inst_age.sh
https://github.com/CULTofBEETROOT/monVPNperso/local4ssh_macOs.sh
```
then run the script:
```
cd ~/Desktop
chmod +x local4macOs_inst_age.sh
./local4macOs_inst_age.sh
chmod -x local4ssh_macOs.sh
./local4ssh_macOs.sh
cat "$HOME"/.ssh/vps4wireguard*.pub
```
#

### for Linux users (here Debian-based)
Open Terminal and download from root or sudoer with :
```
sudo mkdir -p /root/scripts/
sudo wget  -P /root/scripts/ "https://github.com/CULTofBEETROOT/monVPNperso/local4linux_inst_age.sh"
chmod -x /root/scripts/local4linux_inst_age.sh
sudo bash  /root/scripts/local4linux_inst_age.sh
sudo wget -P /root/scripts/ "https://github.com/CULTofBEETROOT/monVPNperso/local4ssh_linux.sh"
chmod -x /root/scripts/local4ssh_linux.sh
sudo bash /root/scripts/local4ssh_linux.sh
cat /root/.ssh/vps4wireguard*.pub
```
#


## THEN INSTALL Debian TRIXIE ON YOUR VPS 
+ from the VPS controle pannel,

  and when allowed, pre-install your SSH public key -the last line in your terminal- via the (Web) Controle Pannel.

  (if you don't find where to install Debian Trixie read your email from the provider and/or login to your online account)




