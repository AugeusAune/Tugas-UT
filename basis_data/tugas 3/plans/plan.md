# Tugas 3 Basis Data (MSIM4206) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Membangun lingkungan basis data terdistribusi multi-node (Master–Slave) via Docker Compose, menguji integritas transaksi ACID & trigger pengurangan stok otomatis, serta menyusun laporan akademik terverifikasi lengkap (Markdown, DOCX, PDF).

**Architecture:** Dua node DBMS MySQL terisolasi dalam satu virtual network Docker Compose (`mysql_master` dengan binlog aktif pada port 3306 dan `mysql_slave` dengan relay-log aktif pada port 3307), masing-masing dihubungkan ke UI phpMyAdmin (`pma_master` port 8080 dan `pma_slave` port 8081). Transaksi ACID (`COMMIT`/`ROLLBACK`/`SAVEPOINT`) dan event trigger (`tg_jual`) dijalankan pada basis data `rumahsakit` yang dilanjutkan dari Tugas 2, lalu disinkronkan ke server Slave secara real-time via MySQL Replication protocol.

**Tech Stack:** MySQL 8.0/latest, phpMyAdmin, Docker & Docker Compose, Bash, Python 3 (`python-docx`), Chromium Headless.

**Spec:** [`basis_data/tugas 3/plans/spec.md`](./spec.md)

---

## Global Constraints

- **Scope Boundary:** Seluruh berkas eksekusi, konfigurasi, skrip SQL, artefak, dan laporan wajib berlokasi di dalam direktori `basis_data/tugas 3/`.
- **Top-Level Cleanliness:** Folder `basis_data/tugas 3/` pada level root hanya boleh memuat `docker-compose.yml`, `README.md`, `tugas3_basis_data.md`, serta subdirektori `plans/`, `artifacts/`, `reports/`, `config/`, `init/`, dan `scripts/`.
- **Zero Bloat / YAGNI:** Dilarang menginstal daemon/paket luar yang tidak dibutuhkan. Gunakan fitur bawaan MySQL replication dan virtualenv terisolasi sementara untuk konversi laporan.
- **Reporting Convention:** Folder `reports/` wajib secara ketat memuat tepat 1 file `.docx` dan 1 file `.pdf`.
- **Single Source of Truth:** Seluruh tangkapan layar bukti eksekusi disimpan di `artifacts/assets/` dengan penamaan deskriptif.

---

## Review Focus

1. **InnoDB Engine Verification:** Storage engine tabel-tabel lama dari Tugas 2 harus diverifikasi `Engine=InnoDB`; jika MyISAM, transaksi ACID dan foreign key cascade akan diabaikan tanpa error eksplisit.
2. **Replication Privileges & User Host:** User replikasi (`prodisi`) harus diizinkan dari host `%` atau subnet bridge docker (`172.%.%.%`), bukan `localhost`, agar Slave dapat melakukan otentikasi.
3. **Binlog Position Drift:** Posisi `MASTER_LOG_POS` harus dibaca segera setelah skema awal diekspor/dikunci atau sebelum ada query tulis baru agar pointer log Slave tidak tertinggal (*out of sync*).
4. **Trigger Negative Stock Guard:** Pengurangan stok pada trigger `tg_jual` harus dipastikan bekerja pada `id_obat` yang sesuai dengan item pada baris `transaksi_obat` baru (`NEW.id_obat`).
5. **Slave Thread Health:** Baik `Slave_IO_Running` maupun `Slave_SQL_Running` keduanya wajib bernilai `Yes`. Jika salah satu bernilai `No`, replikasi belum valid.

---

### Task 1: Scaffolding Environment Multi-Container Master–Slave

**Files:**
- Create: `basis_data/tugas 3/config/master.cnf`
- Create: `basis_data/tugas 3/config/slave.cnf`
- Create: `basis_data/tugas 3/init/01_rumahsakit_tugas2.sql`
- Create: `basis_data/tugas 3/docker-compose.yml`

**Interfaces:**
- Consumes: Skema Tugas 2 dari `basis_data/tugas 2/tugas2_basis_data.md`
- Produces: Service `mysql_master` (port 3306) dan `mysql_slave` (port 3307) siap beroperasi

- [ ] **Step 1: Buat konfigurasi MySQL Master**
  Tulis konfigurasi ke `basis_data/tugas 3/config/master.cnf`:
  ```ini
  [mysqld]
  server-id=1
  log-bin=mysql-bin
  binlog-format=ROW
  binlog-do-db=rumahsakit
  default_authentication_plugin=mysql_native_password
  ```

- [ ] **Step 2: Buat konfigurasi MySQL Slave**
  Tulis konfigurasi ke `basis_data/tugas 3/config/slave.cnf`:
  ```ini
  [mysqld]
  server-id=2
  relay-log=mysql-relay-bin
  read-only=1
  default_authentication_plugin=mysql_native_password
  ```

- [ ] **Step 3: Buat skrip inisialisasi skema Tugas 2**
  Tulis skrip ke `basis_data/tugas 3/init/01_rumahsakit_tugas2.sql` yang memuat `CREATE DATABASE IF NOT EXISTS rumahsakit;`, 6 tabel tugas 2 (`administrator`, `dokter`, `pasien`, `dokter_admin`, `pasien_dokter`, `daftar`), relasi FK, dan data awal pasien (`id_pasien=3, nama_pasien='Popi'`).

- [ ] **Step 4: Buat `docker-compose.yml`**
  Rancang `basis_data/tugas 3/docker-compose.yml` yang menghubungkan `mysql_master` (3306), `mysql_slave` (3307), `pma_master` (8080), dan `pma_slave` (8081) dalam satu jaringan bridge `tugas3_net`.

- [ ] **Step 5: Jalankan container dan verifikasi status**
  Run: `cd "basis_data/tugas 3" && docker compose up -d && sleep 5 && docker compose ps`  
  Expected: 4 container (`mysql_tugas3_master`, `mysql_tugas3_slave`, `pma_tugas3_master`, `pma_tugas3_slave`) berstatus `Up` / running.

- [ ] **Step 6: Commit**
  ```bash
  git add "basis_data/tugas 3/config/" "basis_data/tugas 3/init/" "basis_data/tugas 3/docker-compose.yml"
  git commit -m "feat(tugas3): scaffold multi-container master slave environment"
  ```

---

### Task 2: Praktikum Transaksi (Commit, Rollback, dan Savepoint)

**Files:**
- Create: `basis_data/tugas 3/scripts/01_praktikum_transaksi.sql`

**Interfaces:**
- Consumes: Basis data `rumahsakit` pada `mysql_master`
- Produces: Prosedur `transaksi1`, `transaksi2`, bukti eksekusi commit, rollback, dan savepoint

- [ ] **Step 1: Tulis skrip verifikasi InnoDB dan pengujian transaksi**
  Buat `basis_data/tugas 3/scripts/01_praktikum_transaksi.sql` berisi:
  1. `SHOW TABLE STATUS FROM rumahsakit WHERE Name = 'pasien';`
  2. Prosedur `transaksi1` (DML insert pasien ID 6 tanpa `COMMIT`).
  3. `CALL transaksi1;` dan cek `SELECT * FROM pasien WHERE id_pasien = 6;` (hasil kosong).
  4. Prosedur `transaksi2` (DML insert pasien ID 6 dengan `COMMIT;`).
  5. `CALL transaksi2;` dan cek `SELECT * FROM pasien WHERE id_pasien = 6;` (hasil ada 1 baris).
  6. Transaksi Rollback: `START TRANSACTION; UPDATE pasien SET nama_pasien = 'Danar' WHERE id_pasien = 3; ROLLBACK;` lalu cek nama tetap 'Popi'.
  7. Transaksi Savepoint: Uji pemulihan parsial `SAVEPOINT sp1;` dan `ROLLBACK TO sp1;`.

- [ ] **Step 2: Eksekusi skrip transaksi pada Master**
  Run: `docker exec -i mysql_tugas3_master mysql -u root -proot rumahsakit < "basis_data/tugas 3/scripts/01_praktikum_transaksi.sql"`  
  Expected:
  - Table engine pasien adalah `InnoDB`.
  - Pasien 6 tidak muncul setelah `transaksi1`.
  - Pasien 6 muncul setelah `transaksi2`.
  - Pasien 3 tetap bernama 'Popi' setelah rollback.

- [ ] **Step 3: Tangkap screenshot bukti transaksi**
  Simpan tangkapan layar hasil query ke `basis_data/tugas 3/artifacts/assets/` (`transaksi1_tanpa_commit.png`, `transaksi2_commit.png`, `transaksi3_rollback.png`).

- [ ] **Step 4: Commit**
  ```bash
  git add "basis_data/tugas 3/scripts/01_praktikum_transaksi.sql" "basis_data/tugas 3/artifacts/assets/"
  git commit -m "feat(tugas3): verify inno_db engine and acid transactions"
  ```

---

### Task 3: Praktikum Trigger Pengurangan Stok Obat

**Files:**
- Create: `basis_data/tugas 3/scripts/02_praktikum_trigger.sql`

**Interfaces:**
- Consumes: Basis data `rumahsakit` pada `mysql_master`
- Produces: Tabel `obat`, tabel `transaksi_obat`, trigger `tg_jual`

- [ ] **Step 1: Tulis skrip DDL tabel obat, transaksi_obat, dan trigger**
  Buat `basis_data/tugas 3/scripts/02_praktikum_trigger.sql` berisi:
  ```sql
  -- Tabel obat
  CREATE TABLE IF NOT EXISTS obat (
      id_obat INT(6) AUTO_INCREMENT PRIMARY KEY,
      kode_obat VARCHAR(5),
      nama_obat VARCHAR(30),
      harga INT(10),
      stok INT(5)
  ) ENGINE=InnoDB;

  -- Tabel transaksi_obat
  CREATE TABLE IF NOT EXISTS transaksi_obat (
      id_transaksi INT(3) AUTO_INCREMENT PRIMARY KEY,
      id_pasien INT(3),
      id_obat INT(3),
      jumlah INT(10),
      total_harga INT(10),
      FOREIGN KEY (id_pasien) REFERENCES pasien(id_pasien) ON DELETE CASCADE,
      FOREIGN KEY (id_obat) REFERENCES obat(id_obat) ON DELETE CASCADE
  ) ENGINE=InnoDB;

  -- Seed data obat
  INSERT INTO obat (id_obat, kode_obat, nama_obat, harga, stok) VALUES
  (1, 'A001', 'Amoxillin', 5000, 20),
  (2, 'A002', 'Paracetamol', 3000, 50),
  (3, 'A003', 'Antasida', 4000, 30)
  ON DUPLICATE KEY UPDATE nama_obat=VALUES(nama_obat);

  -- Trigger tg_jual
  DROP TRIGGER IF EXISTS tg_jual;
  DELIMITER $$
  CREATE TRIGGER tg_jual
  AFTER INSERT ON transaksi_obat
  FOR EACH ROW
  BEGIN
      UPDATE obat SET stok = stok - NEW.jumlah
      WHERE id_obat = NEW.id_obat;
  END$$
  DELIMITER ;
  ```

- [ ] **Step 2: Eksekusi skrip pembuatan trigger**
  Run: `docker exec -i mysql_tugas3_master mysql -u root -proot rumahsakit < "basis_data/tugas 3/scripts/02_praktikum_trigger.sql"`  
  Expected: Query berhasil tanpa error syntax.

- [ ] **Step 3: Uji fungsionalitas trigger tg_jual**
  Run: `docker exec -i mysql_tugas3_master mysql -u root -proot rumahsakit -e "INSERT INTO transaksi_obat (id_pasien, id_obat, jumlah, total_harga) VALUES (3, 1, 5, 25000); SELECT * FROM obat WHERE id_obat = 1;"`  
  Expected: Kolom `stok` pada Amoxillin berubah dari 20 menjadi 15.

- [ ] **Step 4: Tangkap screenshot bukti tabel dan trigger**
  Simpan screenshot ke `basis_data/tugas 3/artifacts/assets/` (`create_tabel_obat.png`, `create_tabel_transaksi_obat.png`, `create_trigger_tg_jual.png`, `uji_trigger_stok_berkurang.png`).

- [ ] **Step 5: Commit**
  ```bash
  git add "basis_data/tugas 3/scripts/02_praktikum_trigger.sql" "basis_data/tugas 3/artifacts/assets/"
  git commit -m "feat(tugas3): implement obat tables and tg_jual stock trigger"
  ```

---

### Task 4: Praktikum Basis Data Terdistribusi (Replikasi Master–Slave)

**Files:**
- Create: `basis_data/tugas 3/scripts/03_setup_replication.sh`

**Interfaces:**
- Consumes: `mysql_master` dan `mysql_slave`
- Produces: Sinkronisasi aktif Master-Slave dengan status `Slave_IO_Running=Yes` dan `Slave_SQL_Running=Yes`

- [ ] **Step 1: Tulis script otomasi setup replikasi**
  Buat `basis_data/tugas 3/scripts/03_setup_replication.sh`:
  1. Buat user `prodisi` di Master:
     `CREATE USER IF NOT EXISTS 'prodisi'@'%' IDENTIFIED WITH mysql_native_password BY 'prodisi'; GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'prodisi'@'%'; FLUSH PRIVILEGES;`
  2. Dump data dan skema `rumahsakit` dari Master ke Slave agar baseline data identik.
  3. Ambil nilai `File` dan `Position` dari `SHOW MASTER STATUS;`.
  4. Eksekusi pada Slave:
     `STOP SLAVE; CHANGE MASTER TO MASTER_HOST='mysql_master', MASTER_USER='prodisi', MASTER_PASSWORD='prodisi', MASTER_LOG_FILE='<FILE>', MASTER_LOG_POS=<POS>; START SLAVE;`
  5. Cek `SHOW SLAVE STATUS\G`.

- [ ] **Step 2: Jalankan skrip konfigurasi replikasi**
  Run: `bash "basis_data/tugas 3/scripts/03_setup_replication.sh"`  
  Expected: Output `Slave_IO_Running: Yes` dan `Slave_SQL_Running: Yes`.

- [ ] **Step 3: Uji replikasi real-time dari Master ke Slave**
  1. Tambah data obat baru di Master:
     `INSERT INTO obat (kode_obat, nama_obat, harga, stok) VALUES ('A005', 'Demam', 150, 100);`
  2. Verifikasi data pada Slave:
     `docker exec -i mysql_tugas3_slave mysql -u root -proot rumahsakit -e "SELECT * FROM obat WHERE kode_obat='A005';"`  
  Expected: 1 row returned pada server Slave dengan data obat 'Demam'.

- [ ] **Step 4: Tangkap screenshot bukti replikasi**
  Simpan ke `basis_data/tugas 3/artifacts/assets/` (`master_status.png`, `slave_status_running.png`, `uji_replikasi_insert_master.png`, `uji_replikasi_hasil_slave.png`).

- [ ] **Step 5: Commit**
  ```bash
  git add "basis_data/tugas 3/scripts/03_setup_replication.sh" "basis_data/tugas 3/artifacts/assets/"
  git commit -m "feat(tugas3): configure mysql master slave replication and verify sync"
  ```

---

### Task 5: Dokumentasi, Laporan Markdown, & README Operasional

**Files:**
- Create: `basis_data/tugas 3/README.md`
- Create: `basis_data/tugas 3/tugas3_basis_data.md`

**Interfaces:**
- Consumes: Hasil eksekusi Task 1-4 dan aset gambar di `artifacts/assets/`
- Produces: Dokumentasi lengkap dan naskah pelaporan tugas

- [ ] **Step 1: Tulis dokumentasi operasional `README.md`**
  Rancang panduan lengkap di `basis_data/tugas 3/README.md` yang memuat tabel port container, kredensial login, perintah up/down docker, cara memeriksa status slave replication, dan instruksi pengetesan.

- [ ] **Step 2: Susun naskah laporan komprehensif `tugas3_basis_data.md`**
  Rancang naskah laporan formal yang mencakup elemen wajib UT:
  - Identitas mahasiswa (Farhan Aditya / 054750333).
  - Soal dan analisis teknis ERD rumah sakit.
  - Langkah praktik Transaksi (Commit, Rollback, Savepoint).
  - Langkah praktik Trigger (Tabel `obat`, `transaksi_obat`, trigger `tg_jual`).
  - Langkah praktik Replikasi Master–Slave (Konfigurasi, Status Thread, dan Sinkronisasi data).
  - Pembahasan hasil & Kesimpulan penutup.

- [ ] **Step 3: Verifikasi keberadaan dan integritas file dokumen**
  Run: `test -f "basis_data/tugas 3/README.md" && test -f "basis_data/tugas 3/tugas3_basis_data.md"`  
  Expected: Exit code 0.

- [ ] **Step 4: Commit**
  ```bash
  git add "basis_data/tugas 3/README.md" "basis_data/tugas 3/tugas3_basis_data.md"
  git commit -m "docs(tugas3): write comprehensive report markdown and operational readme"
  ```

---

### Task 6: Kompilasi Dokumen Laporan Profesional (DOCX & PDF)

**Files:**
- Create: `basis_data/tugas 3/artifacts/index.html`
- Create: `basis_data/tugas 3/reports/Laporan_Tugas_3_MSIM4206_Basis_Data.docx`
- Create: `basis_data/tugas 3/reports/Laporan_Tugas_3_MSIM4206_Basis_Data.pdf`

**Interfaces:**
- Consumes: `tugas3_basis_data.md` dan `artifacts/assets/`
- Produces: Tepat 1 file DOCX dan 1 file PDF final di folder `reports/`

- [ ] **Step 1: Buat template HTML presisi di `artifacts/index.html`**
  Susun `basis_data/tugas 3/artifacts/index.html` dengan styling cetak CSS A4 elegan (margin 20mm, tipografi Inter/Roboto, styling tabel formal, format code block rapi, dan gambar bukti berbingkai).

- [ ] **Step 2: Generate PDF via Headless Chromium**
  Run: `~/.cache/ms-playwright/chromium-*/chrome-linux64/chrome --headless --no-sandbox --no-pdf-header-footer --print-to-pdf="basis_data/tugas 3/reports/Laporan_Tugas_3_MSIM4206_Basis_Data.pdf" "basis_data/tugas 3/artifacts/index.html"`  
  Expected: File PDF terbentuk dan berukuran valid (> 1 MB).

- [ ] **Step 3: Generate DOCX via python-docx script**
  Jalankan generator Python untuk membuat dokumen Word dengan margin standar, tabel ber-border rapi, heading berjenjang, dan gambar berskala proporsional ke `basis_data/tugas 3/reports/Laporan_Tugas_3_MSIM4206_Basis_Data.docx`.

- [ ] **Step 4: Verifikasi visual laporan akhir**
  Periksa isi folder `reports/`:
  Run: `ls -lh "basis_data/tugas 3/reports/"`  
  Expected: Tepat 2 file (1 DOCX, 1 PDF), tidak ada file duplikat.

- [ ] **Step 5: Commit dan Push**
  ```bash
  git add "basis_data/tugas 3/artifacts/index.html" "basis_data/tugas 3/reports/"
  git commit -m "chore(tugas3): generate professional docx and pdf reports"
  git push origin main
  ```
