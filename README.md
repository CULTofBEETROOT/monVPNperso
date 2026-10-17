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

download and save in "$HOME\Desktop" the file from the url :
```
https://github.com/CULTofBEETROOT/monVPNperso/local4windows_inst_age.ps1
```
try to run this file :
```
cd "$HOME\Desktop"
.\local4windows_inst_age.ps1
```
IF!!! Windows blocks running scripts, allow it for this PowerShell window only, then run the script:
```
cd "$HOME\Desktop"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\local4windows_inst_age.ps1
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
```
then run the script:
```
cd ~/Desktop
chmod +x local4macOs_inst_age.sh
./local4macOs_inst_age.sh
```
#

### for Linux users (here Debian-based)

Open Terminal and download from root or sudoer with :
```
sudo mkdir -p /root/scripts/
sudo wget  -P /root/scripts/ "https://github.com/CULTofBEETROOT/monVPNperso/local4linux_inst_age.sh"
chmod -x /root/scripts/local4linux_inst_age.sh
bash  /root/scripts/local4linux_inst_age.sh
```
#


