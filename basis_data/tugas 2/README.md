# Panduan Praktikum & Dokumentasi Tugas 2 – Basis Data (MSIM4206)

Dokumentasi ini disusun untuk memenuhi ketentuan **Tugas 2 Basis Data (MSIM4206)** Universitas Terbuka dan menjadi panduan komprehensif perekaman video praktikum yang mencakup **17 langkah panduan praktikum**.

---

## Identitas Mahasiswa

- **Nama**: Farhan Aditya
- **NIM**: 054750333
- **Program Studi**: Sistem Informasi
- **Mata Kuliah**: Basis Data (MSIM4206)
- **Topik**: Implementasi ERD Rumah Sakit dan Operasi SQL Lengkap (17 Langkah Praktikum)

---

## 1. Arsitektur Lingkungan & Layanan

Lingkungan pengujian disediakan dalam format container Docker Compose (atau dapat menggunakan instalasi XAMPP lokal):

| Layanan | Nama Container | Image | Port (Host:Container) | Keterangan |
| :--- | :--- | :--- | :--- | :--- |
| **mysql** | `mysql_tugas2` | `mysql:latest` | `3306:3306` | DBMS MySQL Server (Storage Engine InnoDB) |
| **phpmyadmin** | `pma_tugas2` | `phpmyadmin/phpmyadmin:latest` | `8080:80` | Web UI Pengelola Basis Data |

### Kredensial & Akses

| Komponen | Host / URL | Username | Password | Database Utama |
| :--- | :--- | :--- | :--- | :--- |
| **MySQL CLI** | `localhost:3306` | `root` | `root` | `rumah_sakit` |
| **MySQL User** | `localhost:3306` | `mysql` | `mysql` | `rumah_sakit` |
| **phpMyAdmin** | `http://localhost:8080` | Auto-login (`root`) | Auto-login (`root`) | `rumah_sakit` |

---

## 2. Perintah Operasional Cepat

Jalankan perintah berikut di direktori `basis_data/tugas 2/`:

```bash
# 1. Menjalankan container di background
docker compose up -d

# 2. Memeriksa status container
docker compose ps

# 3. Masuk ke terminal MySQL CLI
docker exec -it mysql_tugas2 mysql -u root -proot

# 4. Menjalankan seluruh skrip 17 langkah sekaligus
docker exec -i mysql_tugas2 mysql -u root -proot < scripts/praktikum_tugas2.sql

# 5. Menghentikan container
docker compose down

# 6. Menghentikan dan membersihkan volume data (reset total)
docker compose down -v
```

---

## 3. Skenario Perekaman Video Praktikum (17 Langkah Lengkap)

Sesuai ketentuan rubrik penilaian tugas UT, video wajib memuat:
1. **Perkenalan Identitas Mahasiswa**
2. **Langkah-Langkah Praktik Beserta Aktivitas Mahasiswa (Poin 1 s.d. 17)**
3. **Hasil Praktik**
4. **Kata Penutup**

Berikut adalah urutan skrip dan alur tindakan yang harus diperagakan saat merekam video:

### Bagian I: Pembukaan (Menit 00:00 - 00:45)
- Tampilkan wajah atau perkenalkan diri di depan mikrofon:
  > "Halo, perkenalkan nama saya Farhan Aditya, NIM 054750333, mahasiswa Program Studi Sistem Informasi Universitas Terbuka. Pada video ini, saya akan mendemonstrasikan pelaksanaan praktikum Tugas 2 Mata Kuliah Basis Data (MSIM4206) berdasarkan 17 langkah panduan praktikum, mulai dari akses MySQL CLI, phpMyAdmin, DDL pembuatan tabel dan relasi ERD Rumah Sakit, hingga manipulasi data menggunakan DML dan query analitik."

---

### Bagian II: Pelaksanaan 17 Langkah Praktikum

#### Langkah 1: Akses MySQL dari Command Prompt
- Buka terminal / Command Prompt.
- Jalankan perintah:
  ```bash
  # Via Docker:
  docker exec -it mysql_tugas2 mysql -u root -proot
  
  # Atau via XAMPP Windows:
  cd C:\xampp\mysql\bin
  mysql -u root -p
  ```
- Jelaskan: Muncul *welcome banner* MySQL Monitor dengan prompt `mysql>`.

#### Langkah 2: Akses PhpMyAdmin
- Buka browser (Chrome/Edge), arahkan ke URL:
  - Docker: `http://localhost:8080`
  - XAMPP: `http://localhost/phpmyadmin`
- Jelaskan: Tampilan antarmuka dashboard phpMyAdmin, panel daftar basis data di sisi kiri, tab SQL, dan informasi server basis data.

#### Langkah 3: Pembuatan Basis Data dari Command Prompt / PhpMyAdmin
- Pada terminal MySQL prompt:
  ```sql
  CREATE DATABASE IF NOT EXISTS rumah_sakit;
  SHOW DATABASES;
  USE rumah_sakit;
  ```
- Jelaskan: Basis data `rumah_sakit` berhasil dibuat dan diaktifkan. Tunjukkan juga basis data ini muncul di phpMyAdmin setelah halaman di-refresh.

#### Langkah 4: Drop Database
- Peragakan penghapusan basis data menggunakan basis data uji coba agar aman:
  ```sql
  CREATE DATABASE db_temp_praktikum;
  SHOW DATABASES;
  DROP DATABASE db_temp_praktikum;
  SHOW DATABASES;
  ```
- Jelaskan: Perintah `DROP DATABASE` menghapus basis data beserta seluruh tabel dan datanya secara permanen. Setelah dihapus, `db_temp_praktikum` tidak lagi terdaftar. Pastikan kembali aktif pada `USE rumah_sakit;`.

#### Langkah 5: Pembuatan Seluruh Tabel dari ERD
- Tampilkan diagram ERD Kasus Rumah Sakit (6 entitas: `administrator`, `dokter`, `pasien`, `dokter_admin`, `daftar`, `pasien_dokter`).
- Eksekusi DDL tabel master terlebih dahulu:
  ```sql
  CREATE TABLE administrator (
      id_admin INT(3) PRIMARY KEY AUTO_INCREMENT,
      nama_admin VARCHAR(30) NOT NULL,
      waktu_jaga VARCHAR(100) NOT NULL
  ) ENGINE=InnoDB;

  CREATE TABLE dokter (
      id_dokter INT(3) PRIMARY KEY AUTO_INCREMENT,
      nama_dokter VARCHAR(30) NOT NULL,
      alamat_dokter VARCHAR(100) NOT NULL,
      tanggal_lahir DATE NOT NULL,
      no_hp VARCHAR(15) NOT NULL,
      spesialis VARCHAR(30) NOT NULL,
      waktu_kerja VARCHAR(100) NOT NULL
  ) ENGINE=InnoDB;

  CREATE TABLE pasien (
      id_pasien INT(3) PRIMARY KEY AUTO_INCREMENT,
      nama_pasien VARCHAR(30) NOT NULL,
      alamat_pasien VARCHAR(100) NOT NULL,
      jenis_kelamin INT(1) NOT NULL
  ) ENGINE=InnoDB;

  CREATE TABLE dokter_admin (
      id_data INT(3) PRIMARY KEY AUTO_INCREMENT,
      id_dokter INT(3) NOT NULL,
      id_admin INT(3) NOT NULL
  ) ENGINE=InnoDB;

  CREATE TABLE daftar (
      id_daftar INT(3) PRIMARY KEY AUTO_INCREMENT,
      id_pasien INT(3) NOT NULL,
      id_admin INT(3) NOT NULL
  ) ENGINE=InnoDB;

  CREATE TABLE pasien_dokter (
      id INT(3) PRIMARY KEY AUTO_INCREMENT,
      id_dokter INT(3) NOT NULL,
      id_pasien INT(3) NOT NULL,
      waktu_periksa DATE NOT NULL,
      resep VARCHAR(100) NOT NULL
  ) ENGINE=InnoDB;
  ```
- Verifikasi tabel yang dibuat:
  ```sql
  SHOW TABLES;
  DESCRIBE dokter;
  ```

#### Langkah 6: Setting Primary Key, Foreign Key, dan Relasi Tabel
- Jelaskan bahwa Primary Key sudah didefinisikan saat `CREATE TABLE`.
- Selanjutnya tambahkan relasi referensial *Foreign Key* dengan `ALTER TABLE`:
  ```sql
  ALTER TABLE dokter_admin
      ADD CONSTRAINT fk_dokter_admin_dokter FOREIGN KEY (id_dokter) REFERENCES dokter(id_dokter) ON DELETE CASCADE ON UPDATE CASCADE,
      ADD CONSTRAINT fk_dokter_admin_admin FOREIGN KEY (id_admin) REFERENCES administrator(id_admin) ON DELETE CASCADE ON UPDATE CASCADE;

  ALTER TABLE daftar
      ADD CONSTRAINT fk_daftar_pasien FOREIGN KEY (id_pasien) REFERENCES pasien(id_pasien) ON DELETE CASCADE ON UPDATE CASCADE,
      ADD CONSTRAINT fk_daftar_admin FOREIGN KEY (id_admin) REFERENCES administrator(id_admin) ON DELETE CASCADE ON UPDATE CASCADE;

  ALTER TABLE pasien_dokter
      ADD CONSTRAINT fk_pasien_dokter_dokter FOREIGN KEY (id_dokter) REFERENCES dokter(id_dokter) ON DELETE CASCADE ON UPDATE CASCADE,
      ADD CONSTRAINT fk_pasien_dokter_pasien FOREIGN KEY (id_pasien) REFERENCES pasien(id_pasien) ON DELETE CASCADE ON UPDATE CASCADE;
  ```
- Verifikasi foreign key via SQL:
  ```sql
  SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
  FROM information_schema.KEY_COLUMN_USAGE
  WHERE TABLE_SCHEMA = 'rumah_sakit' AND REFERENCED_TABLE_NAME IS NOT NULL;
  ```
- Buka tab **Designer** di phpMyAdmin dan tunjukkan garis relasi antar 6 tabel yang terhubung rapi.

#### Langkah 7: Penggunaan INSERT
- Masukkan data contoh ke tabel master dan anak:
  ```sql
  -- Administrator
  INSERT INTO administrator (nama_admin, waktu_jaga) VALUES
  ('Siti Aminah', 'Senin-Jumat 08.00-16.00'),
  ('Ahmad Fauzi', 'Senin-Jumat 16.00-24.00'),
  ('Dewi Sartika', 'Sabtu-Minggu 08.00-20.00');

  -- Dokter
  INSERT INTO dokter (nama_dokter, alamat_dokter, tanggal_lahir, no_hp, spesialis, waktu_kerja) VALUES
  ('Budi Harmoko', 'Jl. Melati No. 1 Jakarta', '1982-04-12', '081234567890', 'Umum', 'Senin-Rabu 09.00-14.00'),
  ('Indah Permata', 'Jl. Sudirman No. 45 Jakarta', '1988-09-20', '081298765432', 'Penyakit Dalam', 'Kamis-Sabtu 10.00-16.00'),
  ('Hendra Wijaya', 'Jl. Dahlia No. 12 Bogor', '1979-11-05', '081311223344', 'Anak', 'Senin-Jumat 08.00-12.00'),
  ('Siti Rahma', 'Jl. Mawar No. 7 Depok', '1990-01-15', '081377889900', 'Penyakit Dalam', 'Selasa-Kamis 13.00-18.00');

  -- Pasien
  INSERT INTO pasien (nama_pasien, alamat_pasien, jenis_kelamin) VALUES
  ('Andi Pratama', 'Jl. Mawar No. 5 Bekasi', 1),
  ('Rina Marlina', 'Jl. Anggrek No. 10 Jakarta', 2),
  ('Bambang Pamungkas', 'Jl. Kenanga No. 8 Tangerang', 1),
  ('Siti Nurhaliza', 'Jl. Melati No. 3 Jakarta', 2),
  ('Dedi Kurniawan', 'Jl. Cendana No. 15 Bogor', 1);

  -- Relasi & Transaksi
  INSERT INTO dokter_admin (id_dokter, id_admin) VALUES (1, 1), (2, 1), (3, 2), (4, 3);
  INSERT INTO daftar (id_pasien, id_admin) VALUES (1, 1), (2, 1), (3, 2), (4, 2), (5, 3);
  INSERT INTO pasien_dokter (id_dokter, id_pasien, waktu_periksa, resep) VALUES
  (1, 1, '2026-10-10', 'RSP-001 Paracetamol 500mg, Amoxicillin'),
  (2, 2, '2026-10-12', 'RSP-002 Omeprazole 20mg, Antasida'),
  (3, 1, '2026-10-15', 'RSP-003 Vitamin C, Ibuprofen'),
  (1, 3, '2026-10-18', 'RSP-004 Sirup Paracetamol, Cetirizine'),
  (2, 4, '2026-10-20', 'RSP-005 Metformin 500mg'),
  (4, 5, '2026-10-22', 'RSP-006 Ranitidine 150mg');
  ```

#### Langkah 8: Penggunaan SELECT
- Tampilkan seluruh kolom dan proyeksi kolom tertentu:
  ```sql
  SELECT * FROM dokter;

  SELECT id_pasien AS 'ID', nama_pasien AS 'Nama Pasien', alamat_pasien AS 'Alamat' 
  FROM pasien;
  ```

#### Langkah 9: Penggunaan WHERE
- Filter data berdasarkan kriteria tertentu:
  ```sql
  -- Mencari dokter dengan spesialisasi Penyakit Dalam:
  SELECT id_dokter, nama_dokter, spesialis, no_hp 
  FROM dokter 
  WHERE spesialis = 'Penyakit Dalam';

  -- Mencari pasien perempuan (jenis_kelamin = 2):
  SELECT id_pasien, nama_pasien, alamat_pasien 
  FROM pasien 
  WHERE jenis_kelamin = 2;
  ```

#### Langkah 10: Penggunaan JOIN
- Menggabungkan data dari beberapa tabel yang berelasi:
  ```sql
  -- INNER JOIN 3 tabel (Pasien, Riwayat Periksa, dan Dokter Pemeriksa):
  SELECT 
      pd.id AS no_periksa,
      p.nama_pasien,
      d.nama_dokter,
      d.spesialis,
      pd.waktu_periksa,
      pd.resep
  FROM pasien_dokter pd
  JOIN pasien p ON pd.id_pasien = p.id_pasien
  JOIN dokter d ON pd.id_dokter = d.id_dokter;
  ```

#### Langkah 11: Penggunaan Fungsi Matematika
- Menggunakan fungsi agregasi dan perhitungan numerik:
  ```sql
  -- Menghitung jumlah pasien dan dokter:
  SELECT COUNT(*) AS total_pasien FROM pasien;

  -- Menghitung rata-rata usia dokter dan usia termuda/tertua:
  SELECT 
      ROUND(AVG(TIMESTAMPDIFF(YEAR, tanggal_lahir, '2026-11-01')), 1) AS rata_rata_usia_dokter,
      MIN(tanggal_lahir) AS tgl_lahir_dokter_tertua,
      MAX(tanggal_lahir) AS tgl_lahir_dokter_termuda
  FROM dokter;
  ```

#### Langkah 12: Penggunaan Fungsi String
- Memanipulasi teks dengan fungsi bawaan SQL:
  ```sql
  -- Menggabungkan gelar dan spesialisasi dengan CONCAT:
  SELECT CONCAT('dr. ', nama_dokter, ' (Spesialis ', spesialis, ')') AS profil_dokter 
  FROM dokter;

  -- UPPER, LOWER, dan LENGTH:
  SELECT 
      UPPER(nama_pasien) AS nama_kapital, 
      LOWER(alamat_pasien) AS alamat_kecil,
      LENGTH(nama_pasien) AS panjang_karakter
  FROM pasien;

  -- Ekstraksi substring kode resep:
  SELECT id, resep, SUBSTRING(resep, 1, 7) AS kode_resep 
  FROM pasien_dokter;
  ```

#### Langkah 13: Penggunaan BETWEEN
- Menyeleksi data dalam suatu rentang nilai:
  ```sql
  -- Dokter yang lahir antara tahun 1980 sampai 1989:
  SELECT nama_dokter, spesialis, tanggal_lahir 
  FROM dokter 
  WHERE tanggal_lahir BETWEEN '1980-01-01' AND '1989-12-31';

  -- Pemeriksaan yang dilakukan pada rentang 10 - 18 Oktober 2026:
  SELECT id, id_pasien, waktu_periksa, resep 
  FROM pasien_dokter 
  WHERE waktu_periksa BETWEEN '2026-10-10' AND '2026-10-18';
  ```

#### Langkah 14: Penggunaan LIKE
- Pencarian data menggunakan pencocokan pola (*wildcard*):
  ```sql
  -- Nama pasien berawalan huruf 'S':
  SELECT * FROM pasien WHERE nama_pasien LIKE 'S%';

  -- Nama dokter berakhiran 'Wijaya':
  SELECT * FROM dokter WHERE nama_dokter LIKE '%Wijaya';

  -- Alamat yang mengandung kata 'Jakarta':
  SELECT id_dokter, nama_dokter, alamat_dokter 
  FROM dokter 
  WHERE alamat_dokter LIKE '%Jakarta%';
  ```

#### Langkah 15: Penggunaan ORDER BY
- Mengurutkan hasil query data:
  ```sql
  -- Ascending (A-Z) berdasarkan nama pasien:
  SELECT * FROM pasien ORDER BY nama_pasien ASC;

  -- Descending (termuda ke tertua) berdasarkan tanggal lahir dokter:
  SELECT nama_dokter, tanggal_lahir, spesialis FROM dokter ORDER BY tanggal_lahir DESC;
  ```

#### Langkah 16: Penggunaan GROUP BY
- Pengelompokan data dengan fungsi agregat:
  ```sql
  -- Jumlah pasien per jenis kelamin:
  SELECT 
      CASE jenis_kelamin WHEN 1 THEN 'Laki-laki' ELSE 'Perempuan' END AS jenis_kelamin,
      COUNT(*) AS total_pasien
  FROM pasien 
  GROUP BY jenis_kelamin;

  -- Jumlah pemeriksaan per dokter dengan klausa HAVING (> 1 pemeriksaan):
  SELECT d.nama_dokter, COUNT(pd.id) AS jumlah_periksa
  FROM dokter d
  JOIN pasien_dokter pd ON d.id_dokter = pd.id_dokter
  GROUP BY d.id_dokter, d.nama_dokter
  HAVING COUNT(pd.id) > 1;
  ```

#### Langkah 17: Penggunaan UPDATE
- Memperbarui rekaman data yang ada:
  ```sql
  -- Memperbarui kontak dan waktu kerja dokter (id_dokter = 1):
  UPDATE dokter 
  SET no_hp = '081299998888', waktu_kerja = 'Senin-Jumat 08.00-15.00' 
  WHERE id_dokter = 1;

  -- Verifikasi hasil UPDATE:
  SELECT id_dokter, nama_dokter, no_hp, waktu_kerja FROM dokter WHERE id_dokter = 1;

  -- Memperbarui alamat pasien (id_pasien = 1):
  UPDATE pasien 
  SET alamat_pasien = 'Jl. Boulevard Raya No. 88 Bekasi Barat' 
  WHERE id_pasien = 1;

  -- Verifikasi hasil UPDATE:
  SELECT id_pasien, nama_pasien, alamat_pasien FROM pasien WHERE id_pasien = 1;
  ```

---

### Bagian III: Hasil Praktik (Menit Akhir)
- Tampilkan kembali diagram Designer phpMyAdmin yang menunjukkan 6 tabel terhubung relasi.
- Tunjukkan tabel `information_schema.KEY_COLUMN_USAGE` untuk membuktikan integritas referensial dan seluruh query SQL berjalan tanpa galat.

### Bagian IV: Kata Penutup
- Sampaikan ringkasan singkat:
  > "Demikian demonstrasi seluruh 17 langkah panduan praktikum Tugas 2 Basis Data (MSIM4206). Seluruh tahapan mulai dari instalasi/akses MySQL CLI dan phpMyAdmin, DDL pendefinisian skema ERD, integritas foreign key, manipulasi data INSERT dan UPDATE, hingga kueri analitik SELECT, WHERE, JOIN, fungsi Matematika, fungsi String, BETWEEN, LIKE, ORDER BY, dan GROUP BY telah berhasil dijalankan dengan baik. Terima kasih atas perhatian Bapak/Ibu Tutor."

---

## 4. Berkas dan Laporan Tugas

1. **Skrip SQL Lengkap**: [`scripts/praktikum_tugas2.sql`](./scripts/praktikum_tugas2.sql)
2. **Dokumentasi Laporan Markdown**: [`tugas2_basis_data.md`](./tugas2_basis_data.md)
3. **Format Web & Cetak HTML**: [`artifacts/index.html`](./artifacts/index.html)
4. **Laporan Dokumen Word**: [`reports/Laporan_Tugas_2_MSIM4206_Basis_Data.docx`](./reports/Laporan_Tugas_2_MSIM4206_Basis_Data.docx)
5. **Laporan Dokumen PDF**: [`reports/Laporan_Tugas_2_MSIM4206_Basis_Data.pdf`](./reports/Laporan_Tugas_2_MSIM4206_Basis_Data.pdf)
