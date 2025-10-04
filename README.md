# 🔄 Restore MikroTik Config (Dual ISP + PBR)

[![RouterOS](https://img.shields.io/badge/RouterOS-7.20-green)](https://github.com/dmxbreaker/restore-mymikrotik)  
[![Device](https://img.shields.io/badge/Device-hAP%20ax²-blue)](https://github.com/dmxbreaker/restore-mymikrotik)  
[![Status](https://img.shields.io/badge/Config-Tested-success)](https://github.com/dmxbreaker/restore-mymikrotik)  
[![Fetch](https://img.shields.io/badge/Fetch%20%26%20Import-Ready-orange)](https://github.com/dmxbreaker/restore-mymikrotik)  
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](https://github.com/dmxbreaker/restore-mymikrotik)

Konfigurasi **RouterOS 7.20 (hAP ax²)** dengan **Dual ISP (Telkom + Fastlink)** dan **Policy Based Routing (PBR)**.  

- **ISP1 (Telkom)** → khusus trafik *Mobile Legends*  
- **ISP2 (Fastlink)** → default untuk seluruh trafik lain  
- **Bridge LAN** → ether1, ether4, ether5, wifi1, wifi2  
- **LAN IP** → `10.10.0.1/12`  
- **Bypass LOCAL** → trafik internal tidak ikut PBR  
- **NAT aktif di kedua ISP**

---

## ⚙️ Sebelum Restore (Tutorial *Pre-Install*)

Setelah **reset configuration**, router masih kosong dan belum bisa `fetch` dari internet.  
Lakukan langkah-langkah berikut di terminal MikroTik agar bisa online:

1️⃣ **Tambahkan DHCP Client di kedua port WAN**  
```rsc
/ip/dhcp-client/add interface=ether2 use-peer-dns=no add-default-route=yes comment="DHCP ISP1 (Telkom)"
/ip/dhcp-client/add interface=ether3 use-peer-dns=no add-default-route=yes comment="DHCP ISP2 (Fastlink)"
```

2️⃣ **Atur DNS (AdGuard + Google + Cloudflare)**  
```rsc
/ip/dns/set servers=94.140.14.14,94.140.15.15,8.8.8.8,1.1.1.1 allow-remote-requests=yes
```

3️⃣ **Tambahkan NAT Masquerade untuk keduanya**  
```rsc
/ip/firewall/nat/add chain=srcnat out-interface=ether2 action=masquerade comment="NAT ISP1 Telkom"
/ip/firewall/nat/add chain=srcnat out-interface=ether3 action=masquerade comment="NAT ISP2 Fastlink"
```

4️⃣ **Aktifkan NTP Client (sinkronisasi waktu)**  
```rsc
/system/ntp/client/set enabled=yes mode=unicast
/system/ntp/client/servers/add address=id.pool.ntp.org
/system/ntp/client/servers/add address=1.id.pool.ntp.org
/system/ntp/client/servers/add address=2.id.pool.ntp.org
```

Jika sudah, cek koneksi internet:  
```rsc
/ping 8.8.8.8
```
Jika berhasil reply ✅ maka router siap menjalankan perintah *fetch*.

---

## ⚡ Quick Restore (1 Langkah)

Jalankan perintah berikut langsung di terminal MikroTik:  

```rsc
/tool fetch url="https://raw.githubusercontent.com/dmxbreaker/restore-mymikrotik/main/scripts/dualisp-ml-pbr.rsc" mode=https dst-path=dualisp-ml-pbr.rsc;
/import file=dualisp-ml-pbr.rsc
```

---

## 📂 File

- `scripts/dualisp-ml-pbr.rsc` → konfigurasi lengkap siap di-import  

---

## 💾 Backup Config

Sebelum melakukan perubahan, selalu simpan konfigurasi:

```rsc
/export file=config-backup
/system/backup/save name=full-backup
```

Struktur folder yang direkomendasikan:

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

## 🧩 Interface Mapping

| Interface | Fungsi | Keterangan |
|------------|---------|-------------|
| **ether1** | LAN | anggota bridge-LAN |
| **ether2** | ISP1 | Telkom (Mobile Legends) |
| **ether3** | ISP2 | Fastlink (Default Internet) |
| **ether4–5** | LAN | anggota bridge-LAN |
| **wifi1–2** | WLAN | anggota bridge-LAN |
| **bridge-LAN** | Bridge utama LAN | IP: 10.10.0.1/12 |

---

## 📸 Screenshots (Opsional)

### Routing Table
```rsc
/ip/route/print
```

### Firewall Mangle Rules
```rsc
/ip/firewall/mangle/print
```



---

## 🔍 Post-Install Verification (Opsional)

Gunakan perintah berikut untuk memastikan konfigurasi sudah aktif:

```rsc
/interface/bridge/print
/ip/address/print
/ip/route/print
/ip/firewall/nat/print
/ip/firewall/mangle/print
/routing/table/print
:put [:resolve "google.com"]

```
---

✍️ **Maintainer:** [dmxbreaker](https://github.com/dmxbreaker)  
📆 **Last Update:** Oktober 2025  
🧩 **License:** MIT
