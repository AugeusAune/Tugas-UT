# Dokumentasi Docker Compose – MySQL & phpMyAdmin

Dokumentasi ini menjelaskan konfigurasi dan penggunaan lingkungan basis data berbasis Docker untuk pengerjaan **Tugas 2 Basis Data (MSIM4206)**.

---

## 1. Arsitektur Layanan

| Service | Container Name | Image | Port (Host:Container) | Keterangan |
| :--- | :--- | :--- | :--- | :--- |
| **mysql** | `mysql_tugas2` | `mysql:latest` | `3306:3306` | DBMS MySQL server |
| **phpmyadmin** | `pma_tugas2` | `phpmyadmin/phpmyadmin:latest` | `8080:80` | Web UI Database Manager |

Data MySQL disimpan secara persisten menggunakan Docker named volume `mysql_data`.

---

## 2. Kredensial & Akses

| Komponen | Host / URL | Username | Password | Database Bawaan |
| :--- | :--- | :--- | :--- | :--- |
| **MySQL (Root)** | `localhost:3306` | `root` | `root` | `rumahsakit` |
| **MySQL (User)** | `localhost:3306` | `mysql` | `mysql` | `rumahsakit` |
| **phpMyAdmin** | `http://localhost:8080` | *Auto-login* | *Auto-login* | `rumahsakit` |

> [!NOTE]
> Akses ke phpMyAdmin tidak memerlukan input kredensial manual karena telah dikonfigurasi auto-login (`PMA_USER: root` dan `PMA_PASSWORD: root`). Saat membuka `http://localhost:8080`, dashboard phpMyAdmin langsung terbuka.

---

## 3. Konfigurasi `docker-compose.yml`

File konfigurasi berada di [`docker-compose.yml`](./docker-compose.yml):

```yaml
services:
  mysql:
    image: mysql:latest
    container_name: mysql_tugas2
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_USER: mysql
      MYSQL_PASSWORD: mysql
      MYSQL_DATABASE: rumahsakit
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    container_name: pma_tugas2
    restart: always
    environment:
      PMA_HOST: mysql
      PMA_PORT: 3306
      PMA_USER: root
      PMA_PASSWORD: root
    ports:
      - "8080:80"
    depends_on:
      - mysql

volumes:
  mysql_data:
```

---

## 4. Perintah Operasional

Jalankan seluruh perintah di dalam folder `program/Tugas-UT/basis_data/tugas 2/`:

### A. Menjalankan Layanan (Background Mode)
```bash
docker-compose up -d
```

### B. Memeriksa Status Container
```bash
docker-compose ps
```

### C. Melihat Log Container
```bash
# Semua log
docker-compose logs -f

# Log MySQL saja
docker-compose logs -f mysql

# Log phpMyAdmin saja
docker-compose logs -f phpmyadmin
```

### D. Masuk ke Terminal MySQL (CLI)
```bash
docker exec -it mysql_tugas2 mysql -u root -proot rumahsakit
```

Atau sebagai user non-root:
```bash
docker exec -it mysql_tugas2 mysql -u mysql -pmysql rumahsakit
```

### E. Menghentikan Layanan
```bash
# Hentikan tanpa menghapus data volume
docker-compose down

# Hentikan dan hapus volume database (reset data dari nol)
docker-compose down -v
```

---

## 5. Menjalankan Skrip DDL Tugas 2

Untuk membuat tabel dan relasi tugas:

### Cara 1: Lewat Browser (phpMyAdmin)
1. Buka browser: [`http://localhost:8080`](http://localhost:8080).
2. Di panel kiri, klik basis data **`rumahsakit`**.
3. Buka tab **SQL**.
4. Tempel (*paste*) perintah `CREATE TABLE` dan `ALTER TABLE` dari file [`tugas2_basis_data.md`](./tugas2_basis_data.md), lalu klik **Go / Kirim**.
5. Buka tab **Designer** untuk melihat diagram relasi tabel yang telah terbentuk.

### Cara 2: Lewat Terminal (Piping Skrip SQL)
Jika skrip SQL tersimpan dalam file `skema.sql`:
```bash
docker exec -i mysql_tugas2 mysql -u root -proot rumahsakit < skema.sql
```
