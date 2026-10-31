# Dokumentasi Docker Compose – Basis Data Terdistribusi (MySQL Master–Slave)

Dokumentasi ini menjelaskan konfigurasi dan penggunaan lingkungan multi-node MySQL berbasis Docker untuk pengerjaan **Tugas 3 Basis Data (MSIM4206)**.

---

## 1. Arsitektur Layanan

| Service | Container Name | Port (Host:Container) | Keterangan |
| :--- | :--- | :--- | :--- |
| **mysql_master** | `mysql_tugas3_master` | `3306:3306` | DBMS Master (`server-id=1`, binlog aktif) |
| **mysql_slave** | `mysql_tugas3_slave` | `3307:3306` | DBMS Slave (`server-id=2`, relay log aktif) |
| **pma_master** | `pma_tugas3_master` | `8080:80` | Web UI Database Manager (Master) |
| **pma_slave** | `pma_tugas3_slave` | `8081:80` | Web UI Database Manager (Slave) |

---

## 2. Kredensial & Akses

| Komponen | Host / URL | Username | Password | Database |
| :--- | :--- | :--- | :--- | :--- |
| **Master (Root)** | `localhost:3306` | `root` | `root` | `rumah_sakit` |
| **Slave (Root)** | `localhost:3307` | `root` | `root` | `rumah_sakit` |
| **User Replikasi** | Internal Docker Net | `prodisi` | `prodisi` | `*.*` (`REPLICATION SLAVE`) |
| **phpMyAdmin Master** | `http://localhost:8080` | *Auto-login* | *Auto-login* | `rumah_sakit` |
| **phpMyAdmin Slave** | `http://localhost:8081` | *Auto-login* | *Auto-login* | `rumah_sakit` |

---

## 3. Perintah Operasional

Jalankan perintah di dalam folder `basis_data/tugas 3/`:

### A. Menjalankan Layanan (Background Mode)
```bash
docker compose up -d
```

### B. Memeriksa Status Container
```bash
docker compose ps
```

### C. Masuk ke Terminal MySQL Master (CLI)
```bash
docker exec -it mysql_tugas3_master mysql -u root -proot rumah_sakit
```

### D. Masuk ke Terminal MySQL Slave (CLI)
```bash
docker exec -it mysql_tugas3_slave mysql -u root -proot rumah_sakit
```

### E. Menjalankan Setup & Verifikasi Replikasi Otomatis
```bash
bash scripts/03_setup_replication.sh
```

### F. Menghentikan Layanan
```bash
# Hentikan container tanpa menghapus volume data
docker compose stop

# Hentikan dan hapus container
docker compose down

# Hentikan dan reset volume (ulang dari nol)
docker compose down -v
```
