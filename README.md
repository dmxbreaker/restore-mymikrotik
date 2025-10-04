# 🔄 Restore MikroTik Config

[![RouterOS](https://img.shields.io/badge/RouterOS-7.20-green)](https://github.com/dmxbreaker/restore-mymikrotik)  
[![Device](https://img.shields.io/badge/Device-hAP%20ax²-blue)](https://github.com/dmxbreaker/restore-mymikrotik)  
[![Status](https://img.shields.io/badge/Config-Tested-success)](https://github.com/dmxbreaker/restore-mymikrotik)  
[![Fetch](https://img.shields.io/badge/Fetch%20%26%20Import-Ready-orange)](https://github.com/dmxbreaker/restore-mymikrotik)  
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](https://github.com/dmxbreaker/restore-mymikrotik)  

Konfigurasi **RouterOS 7.20 (hAP ax²)** dengan Dual ISP + PBR:  

- **ISP1 (Telkom)** → khusus trafik Mobile Legends  
- **ISP2 (Fastlink)** → default semua trafik lain  
- **Bridge LAN** → ether1, ether4, ether5, wifi1, wifi2  
- **LAN IP** → 10.10.0.1/12 (Hotspot)  
- **Bypass LOCAL** → trafik internal tidak ikut PBR  
- **NAT aktif di kedua ISP**

---

## ⚡ Quick Restore (one-liner)

Jalankan perintah ini langsung di terminal MikroTik:  

```rsc
/tool fetch url="https://raw.githubusercontent.com/dmxbreaker/restore-mymikrotik/main/scripts/dualisp-ml-pbr.rsc" mode=https dst-path=dualisp-ml-pbr.rsc; /import file=dualisp-ml-pbr.rsc
```

---

## 📂 File

- `scripts/dualisp-ml-pbr.rsc` → konfigurasi clean siap di-import.  

---

## 🔄 Cara Restore

### 1. Upload manual (Winbox / FTP)

- Upload file ke router (via **Winbox → Files** atau FTP).  
- Import konfigurasi:  

```rsc
/import file=dualisp-ml-pbr.rsc
```

### 2. Restore langsung via GitHub (2 langkah)

```rsc
/tool fetch url="https://raw.githubusercontent.com/dmxbreaker/restore-mymikrotik/main/scripts/dualisp-ml-pbr.rsc" mode=https
/import file=dualisp-ml-pbr.rsc
```

---

## 💾 Backup Config

Export konfigurasi saat ini ke file `.rsc`:  

```rsc
/export file=config-backup
```

Simpan juga binary backup (hanya bisa di-restore di device & ROS yang sama):  

```rsc
/system backup save name=full-backup
```

Struktur repo rekomendasi:  

```
restore-mymikrotik/
├── README.md
├── scripts/
│   └── dualisp-ml-pbr.rsc
└── backups/
    ├── config-backup.rsc
    └── full-backup.backup
```

---

## 📌 Tips GitHub (pakai VS Code + Git CLI)

### Clone repo

```bash
git clone https://github.com/dmxbreaker/restore-mymikrotik.git
cd restore-mymikrotik
```

### Tambahkan file baru

```bash
git add scripts/dualisp-ml-pbr.rsc
git commit -m "update dual ISP + ML config"
git push origin main
```

### Update backup

```bash
git add backups/config-backup.rsc
git commit -m "add latest router export"
git push origin main
```

---

## 📸 Screenshots (Opsional)

### Routing Table

```rsc
/ip route print
```

### Firewall Mangle Rules

```rsc
/ip firewall mangle print
```

---

✍️ Maintainer: **dmxbreaker**  
📌 Last Update: Januari 2025
