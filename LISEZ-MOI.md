# mon VPN perso
toutes les étapes de 0-connaissance à un vpn 100%-installé, -activé, -abordable, ...

<table border="0" align="right">
  <tr>
     <td><a href="README.md">🇺🇸</a></td>
  </tr>
</table>


#
<table>
  <tr>
    <td><img src="images/wireguard_Play.jpg" alt="WIREGUARD Project App on Play store" width="650"></td>
    <td><img src="images/wireguard_App_Store.jpg" alt="WIREGUARD Project App on App Store" width="650"></td>
  </tr>
</table>

## EXIGENCES:
1 PC ou 1 ordinateur portable, fonctionnant soit
*    Linux, ou
*    Windows, ou
*    MacOS (ou dérivé) ... 
1 VPS (par exemple flokinet.is ou 1984.is ou netcup.de, l'offre VPS la plus basique et la plus abordable)

optionnel : vos 100 amis les plus impatients avec leurs appareils de téléphone portable, en suspens en vous regardant.
#


### Utilisateurs Windows

Ouvrez PowerShell ou Windows Terminal et installez avec WinGet:
```
winget install --id FiloSottile.age
```
Fermez et rouvrez le terminal, puis vérifiez qu'il fonctionne:
```
age --versionage-keygen --help
```

Téléchargez et économisez dans "$HOME\Desktop" les fichiers à partir des URL:
```
https://github.com/CULTofBEETROOT/monVPNperso/local4windows_inst_age.ps1
https://github.com/CULTofBEETROOT/monVPNperso/local4ssh_windows.ps1
https://github.com/CULTofBEETROOT/monVPNperso/install_vpn_ON_vps.sh
```
Essayez d'exécuter ce fichier:
```
cd "$HOME\Desktop"
.\local4windows_inst_age.ps1
.\local4ssh_windows.ps1
Get-Content "$HOME\.ssh\vps4wireguard*.pub"
```
DANS l'EVENTUALITE QUE !!! Windows bloque l'exécution des scripts, autorisez-le uniquement pour cette fenêtre PowerShell, puis exécutez le script:
```
cd "$HOME\Desktop"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\local4windows_inst_age.ps1
.\local4ssh_windows.ps1
Get-Content "$HOME\.ssh\vps4wireguard*.pub"
```
#

### utilisateurs de macOS

Ouvrir le terminal et l'installer avec Homebrew:
```
brew install age
```
Vérifiez l'installation:
```
age --versionage-keygen --help
```

Téléchargez le script à partir de cette url et enregistrez le fichier dans "$HOME/Desktop":
```
https://github.com/CULTofBEETROOT/monVPNperso/local4macOs_inst_age.sh
https://github.com/CULTofBEETROOT/monVPNperso/local4ssh_macOs.sh
https://github.com/CULTofBEETROOT/monVPNperso/install_vpn_ON_vps.sh
```
Ensuite, exécutez le script:
```
cd ~/Desktop
chmod +x local4macOs_inst_age.sh
./local4macOs_inst_age.sh
chmod -x local4ssh_macOs.sh
./local4ssh_macOs.sh
cat "$HOME"/.ssh/vps4wireguard*.pub
```
#

### Utilisateurs Linux (ici basé sur Debian)
Ouvrez Terminal et téléchargez depuis root ou sudoer avec :
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
#


ÊTRE CONSCIENT: toute cette page est en cours d'édition et le dernier bit encore manquant est:

+ ajouter votre IP publique VPS dans le script où il y a un détenteur de place en attente (le code de connexion ssh par exemple)
+ ajoutez votre clé Ssh .pub (ci-dessus) à l'espace réservé ssh sur la tête de install_vpn_ON_vps.sh
+ planifier n'importe quelle phase de passage, bientôt seront-ils incités.

## MAINTENANT pour EveryOne : INSTALLER Debian TRIXIE sur votre VPS

+ à partir du panneau de contrôle VPS,

  et lorsque cela est autorisé, pré-installez votre clé publique SSH -la dernière ligne de votre terminal- via le panneau (Web) Controle.

  (si vous ne trouvez pas où installer Debian Trixie, lisez votre email du fournisseur et/ou connectez-vous à votre compte en ligne)

## Une fois que votre vps est en cours d'exécution, laissez-nous copier dans le script qui installera le serveur de wirguard:

### Utilisateurs Windows, copier-coller dans votre terminal Powershell:
```
$key = Get-ChildItem "$HOME\.ssh\vps4wireguard-*" -File |
    Where-Object { $_.Name -notlike "*.pub" } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1 -ExpandProperty FullName

scp -i $key -P 22 "$HOME\scripts\install_vpn_ON_vps.sh" "root@vpsIP:/root/"

```
###
utilisateurs de macOs, copier-coller dans votre terminal:
```
scp -i "$HOME"/.ssh/vps4wireguard-*[!.pub] \
  -P 22 "$HOME/scripts/install_vpn_ON_vps.sh" \
  root@vpsIP:/root/
```

### Utilisateurs Linux, copiez la pâte dans votre terminal:
```
scp -i /root/.ssh/vps4wireguard*[!.pub] -P 22 /root/scripts/install_vpn_ON_vps.sh root@vpsIP:/root/
```

## MAINTENANT pour EveryOne: connectez-vous au VPS
Quelle que soit la manière qui vous appartient:
* Vous avez pu prérégler votre clé publique ssh, vous savez probablement comment vous connecter
* Vous n'avez pas été en mesure de prérégler votre clé publique ssh, vous devez certainement vous connecter avec votre mot de passe root prédéfini (ou envoyé par courriel)

et exécutez le script que nous venons de copier sur l'étape précédente:
1) Vous serez invité pour la lettre y sur la perte (vous ne le ferez pas) votre connexion ssh
2) sur l'adresse IP publique de votre VPS (à partir de vos emails)
3) sur une nouvelle phrase de passe utilisateur non root de votre choix (à retenir car la prochaine fois que vous vous connectez, vous vous connecterez en mode non-root)
4) lorsque deux lignes ont été activées et que vous faites face à un gel, comptez 5 secondes et appuyez sur Ctrl + C, 
   (c'est normal et est dû au réseau),
5) à quel stade vous pouvez quitter la connexion ssh avec:
```
exit 
exit
```

### Utilisateurs Windows, copier-coller dans votre terminal Powershell:
```
$key = Get-ChildItem "$HOME\.ssh\vps4wireguard-*" -File |
    Where-Object { $_.Name -notlike "*.pub" } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1 -ExpandProperty FullName

scp -i $key -P 61525 "vpnadmin@vpsIP:/home/vpnadmin/*.age" "$HOME\Desktop\" 

```

### utilisateurs de macOs, copier-coller dans votre terminal:
```
scp -i "$HOME"/.ssh/vps4wireguard-*[!.pub] \
  -P 61525  vpnadmin@vpsIP:/home/vpnadmin/*.age \
  "$HOME/Desktop/" 
```

### Utilisateurs Linux, copier-coller dans votre terminal:
```
mkdir -p /home/$USER/WGclients
scp -i /root/.ssh/vps4wireguard*[!.pub] -P 61525 vpnadmin@vpsIP:/home/vpnadmin/*.age /home/$USER/Downloads/WGclients/ 
bash /root/scripts/local4linux_age-decyptWGclients.sh
```
#### ouvrir n'importe quel fichier /home/$USER/WGclients/clientXXX.png,
#### scanner le code QR à partir de l'application QR de votre mobile,
#### à savoir:

* (google) Play Store : https://play.google.com/store/apps/details ? id=com.wireguard.android&hl=fr-US

* Apple Store : https://apps.apple.com/us/app/wireguard/id1441195209

* (plus sur F-droid parce que le wilguard se met à jour à partir de leur tunnel VPN et F-droid ne peut pas vérifier les mises à jour).

## FÉLICITATION !
### La navigation et les données de votre téléphone mobile sont maintenant diffusées à partir de votre emplacement VPS.
