# shell

Moje skripte za cPanel, DirectAdmin i "čisti" Linux (AlmaLinux / CentOS / Ubuntu), plus
nešto sitnica za Cloudflare, cloud-init i Windows.

> ⚠️ Skripte se izvršavaju kao **root** i mijenjaju sistemsku konfiguraciju (SELinux,
> firewall, SSH port, web server, PHP...). Prije pokretanja pročitaj skriptu. Većina ih
> nakon izvršavanja obriše samu sebe.

Pokretanje direktno s GitHuba, npr.:

```bash
wget https://raw.githubusercontent.com/icacija/shell/main/cpanel/postinstall.sh
bash postinstall.sh
```

## alma/ — AlmaLinux

| Skripta | Opis |
|---|---|
| `alma-inicial.sh` | početni setup: SELinux i firewall off, SSH port 4444, Europe/Zagreb, EPEL, osnovni alati |
| `alma-zonecloud.sh` | CSE + ZoneCloud agent (EL8) |
| `alma9-zonecloud.sh` | ZoneCloud agent (EL9) |
| `alma-elastic7.sh` | Elasticsearch 7 + Java 11 |
| `alma_wkhtmltopdf.sh` | wkhtmltopdf s fontovima i bibliotekama |

## centos/ — CentOS 7 (EOL)

| Skripta | Opis |
|---|---|
| `centos-inicial.sh` | početni setup (kao `alma-inicial.sh`) |
| `centos-zonecloud.sh` | CSE + ZoneCloud agent (EL7) |

## ubuntu/

| Skripta | Opis |
|---|---|
| `ubuntu_wkhtmltopdf.sh` | wkhtmltopdf za Ubuntu 24.04, s test PDF-om |
| `ubuntu-20.04-elastic.sh` | Elasticsearch 7 na Ubuntu 20.04 |
| `ubuntu-lamp.sh` | minimalni LAMP (Apache, MySQL, PHP) |

## cpanel/

| Skripta | Opis |
|---|---|
| `postinstall.sh` | CSF + CMQ + CSE nakon instalacije cPanela |
| `cse_install.sh` | ConfigServer Explorer |
| `jetbackup.sh` | JetBackup 5 (stable) |
| `mysql_bkp.sh` | dnevni dump svih baza u `/backup/db`, čuva 2 dana |
| `rm_cluster_zones.sh` | backup `/var/named` i micanje zona domena koje nisu na serveru |
| `securetmp_script.sh` | ponovno kreiranje `/tmp` (`/scripts/securetmp`) uz zaustavljanje servisa |
| `ships.sh` / `ships-new.sh` | priprema cPanel servera za ShipShape (Redis, Imagick, Composer); PHP 7.4 / PHP 8.3 |
| `uninstall_wttw.sh` | deinstalacija CSF, CSE i CMQ (waytotheweb) |

## csf/

| Skripta | Opis |
|---|---|
| `csf_init.sh` | osnovna CSF konfiguracija (TESTING off, notifikacije...) |

## directadmin/

| Skripta | Opis |
|---|---|
| `apache.sh` / `apache-ngnix.sh` | prebacivanje na Apache / nginx + Apache |
| `litespeed.sh` / `openlitespeed.sh` | prebacivanje na LiteSpeed / OpenLiteSpeed |
| `litespeed-to-openlitespeed.sh` / `openlitespeed-to-litespeed.sh` | prelazak između LSWS i OLS |
| `rewrite_confs.sh` | `custombuild rewrite_confs` |
| `autologin.sh` | one-click login za phpMyAdmin i Roundcube |
| `da-login.sh` | jednokratni login URL za admina |
| `hostname-ssl.sh` | Let's Encrypt certifikat za hostname |
| `fix_da.sh` | ponovna instalacija DirectAdmin binarke s odabranog kanala |
| `remove_backups.sh` | brisanje starih admin backupa |
| `user_backup_post.sh` | DA hook nakon user backupa |

## Ostalo

| Putanja | Opis |
|---|---|
| `cloud-init/redhat`, `cloud-init/ubuntu` | cloud-config: SSH port 4444, vremenska zona Europe/Zagreb |
| `cloudflare/bbots_2024` | Cloudflare WAF izraz za blokiranje loših botova po User-Agentu |
| `windows/rdp_port_change.ps1` | promjena RDP porta (testirano na Windows Server 2019) |
| `razno/php.ini` | PHP postavke za velike uploade i duge skripte |
| `authorized_keys` | javni SSH ključ |

## Proxmox

Skripte za deploy VM-ova (`vm_deploy.sh`, `improved_vm_deploy.sh`) više nisu ovdje.
Aktualni `vm-deploy` se distribuira interno.

## Licenca

[MIT](LICENSE)
