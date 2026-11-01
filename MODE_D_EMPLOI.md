# 🐧 Mode d'emploi rapide – Fail2Ban Security Suite

Guide simple et direct pour installer et utiliser ce dépôt sur **n'importe quel serveur Debian** (Debian 10, 11, 12 ou dérivées comme Ubuntu).

---

## ⚡ 1. Cloner le dépôt

Sur un serveur Debian neuf (en tant que `root` ou avec `sudo`) :

```bash
# Installer git si absent
apt update && apt install -y git

# Cloner le dépôt et entrer dedans
git clone https://github.com/arthas95/fail2ban-security-suite.git
cd fail2ban-security-suite
```

---

## 🚀 2. Installer et activer la protection

Lancez le script d'installation automatique :

```bash
chmod +x install.sh
./install.sh
```
*(ou `sudo ./install.sh` si vous n'êtes pas connecté en root)*

### Ce que fait le script automatiquement :
- Installe `fail2ban`, `iptables` et `python3-systemd` si nécessaires.
- Déploie toutes les règles de détection durcies (SSH, Mail Postfix/Dovecot, Apache, MariaDB, Squid, BIND9, Récidive multi-prisons).
- Ajoute automatiquement l'adresse IP publique de votre serveur à la liste blanche (`ignoreip`) pour éviter tout auto-bannissement.
- Vérifie la syntaxe de la configuration avec `fail2ban-client -t`.
- Active et redémarre le service `fail2ban`.
- Installe l'outil de bord `f2b-status` dans `/usr/local/bin/`.

---

## 🛡️ 3. Utilisation au quotidien

### Afficher le tableau de bord en direct
Pour visualiser l'état de toutes les prisons et les IP actuellement bannies :
```bash
f2b-status
```

### Vérifier une prison spécifique
```bash
# Exemple pour SSH :
fail2ban-client status sshd

# Exemple pour Postfix :
fail2ban-client status postfix

# Exemple pour les récidivistes (bannissement global 1 semaine) :
fail2ban-client status recidive
```

### Débannir une adresse IP
Si une adresse IP légitime a été bloquée :
```bash
# Débannir d'une prison précise :
fail2ban-client set sshd unbanip 192.0.2.1

# Débannir de TOUTES les prisons :
fail2ban-client unban 192.0.2.1
```

### Bannir manuellement une IP suspecte
```bash
fail2ban-client set sshd banip 192.0.2.1
```

### Ajouter une IP en liste blanche (Whitelist)
Pour vous assurer que votre IP personnelle ou VPN ne soit jamais bannie :
```bash
nano /etc/fail2ban/jail.local
```
Ajoutez votre IP sur la ligne `ignoreip` :
```ini
ignoreip = 127.0.0.1/8 ::1 <VOTRE_IP_ICI>
```
Rechargez ensuite la configuration à chaud sans coupure :
```bash
fail2ban-client reload
```

### Suivre les détections et bannissements en direct
```bash
tail -f /var/log/fail2ban.log
```

---

## 🔄 4. Désinstallation

Pour désactiver la suite et restaurer la configuration standard :
```bash
cd fail2ban-security-suite
./uninstall.sh
```
