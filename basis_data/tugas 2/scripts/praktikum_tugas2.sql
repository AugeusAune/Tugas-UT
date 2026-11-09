-- ============================================================================
-- TUGAS 2 BASIS DATA (MSIM4206) - UNIVERSITAS TERBUKA
-- SKRIP PRAKTIKUM LENGKAP: 17 LANGKAH PANDUAN PRAKTIKUM
-- Kasus Basis Data: Rumah Sakit (Dokter, Pasien, Admin, Relasi)
-- Mahasiswa: Farhan Aditya (NIM: 054750333)
-- Program Studi: Sistem Informasi
-- ============================================================================

-- ----------------------------------------------------------------------------
-- LANGKAH 1: AKSES MYSQL DARI COMMAND PROMPT
-- ----------------------------------------------------------------------------
-- Perintah akses dari terminal host / XAMPP:
--   cd C:\xampp\mysql\bin && mysql -u root -p
-- Atau via Docker container:
--   docker exec -it mysql_tugas2 mysql -u root -proot

-- ----------------------------------------------------------------------------
-- LANGKAH 2: AKSES PHPMYADMIN
-- ----------------------------------------------------------------------------
-- Buka web browser:
--   - Docker: http://localhost:8080
--   - XAMPP : http://localhost/phpmyadmin

-- ----------------------------------------------------------------------------
-- LANGKAH 3: PEMBUATAN BASIS DATA DARI COMMAND PROMPT / PHPMYADMIN
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS rumah_sakit;
SHOW DATABASES;
USE rumah_sakit;

-- ----------------------------------------------------------------------------
-- LANGKAH 4: DROP DATABASE
-- ----------------------------------------------------------------------------
-- Demonstrasi pembuatan basis data sementara dan penghapusannya:
CREATE DATABASE IF NOT EXISTS db_temp_praktikum;
SHOW DATABASES;
DROP DATABASE db_temp_praktikum;
SHOW DATABASES;

-- Pastikan kita aktif menggunakan database tugas utama:
USE rumah_sakit;

-- ----------------------------------------------------------------------------
-- LANGKAH 5: PEMBUATAN SELURUH TABEL DARI ERD
-- ----------------------------------------------------------------------------
-- Tabel dibuat berurutan dari tabel master (induk) lalu tabel transaksi (anak).

-- 1. Tabel administrator
CREATE TABLE IF NOT EXISTS administrator (
    id_admin INT(3) PRIMARY KEY AUTO_INCREMENT,
    nama_admin VARCHAR(30) NOT NULL,
    waktu_jaga VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- 2. Tabel dokter
CREATE TABLE IF NOT EXISTS dokter (
    id_dokter INT(3) PRIMARY KEY AUTO_INCREMENT,
    nama_dokter VARCHAR(30) NOT NULL,
    alamat_dokter VARCHAR(100) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    no_hp VARCHAR(15) NOT NULL,
    spesialis VARCHAR(30) NOT NULL,
    waktu_kerja VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- 3. Tabel pasien
CREATE TABLE IF NOT EXISTS pasien (
    id_pasien INT(3) PRIMARY KEY AUTO_INCREMENT,
    nama_pasien VARCHAR(30) NOT NULL,
    alamat_pasien VARCHAR(100) NOT NULL,
    jenis_kelamin INT(1) NOT NULL -- 1 = Laki-laki, 2 = Perempuan
) ENGINE=InnoDB;

-- 4. Tabel dokter_admin (Relasi Dokter dan Administrator)
CREATE TABLE IF NOT EXISTS dokter_admin (
    id_data INT(3) PRIMARY KEY AUTO_INCREMENT,
    id_dokter INT(3) NOT NULL,
    id_admin INT(3) NOT NULL
) ENGINE=InnoDB;

-- 5. Tabel daftar (Relasi Pasien mendaftar lewat Administrator)
CREATE TABLE IF NOT EXISTS daftar (
    id_daftar INT(3) PRIMARY KEY AUTO_INCREMENT,
    id_pasien INT(3) NOT NULL,
    id_admin INT(3) NOT NULL
) ENGINE=InnoDB;

-- 6. Tabel pasien_dokter (Relasi Pemeriksaan Pasien oleh Dokter)
CREATE TABLE IF NOT EXISTS pasien_dokter (
    id INT(3) PRIMARY KEY AUTO_INCREMENT,
    id_dokter INT(3) NOT NULL,
    id_pasien INT(3) NOT NULL,
    waktu_periksa DATE NOT NULL,
    resep VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- Verifikasi keberadaan dan struktur seluruh tabel:
SHOW TABLES;
DESCRIBE administrator;
DESCRIBE dokter;
DESCRIBE pasien;
DESCRIBE dokter_admin;
DESCRIBE daftar;
DESCRIBE pasien_dokter;

-- ----------------------------------------------------------------------------
-- LANGKAH 6: SETTING PRIMARY KEY, FOREIGN KEY, DAN RELASI TABEL
-- ----------------------------------------------------------------------------
-- Primary key telah diatur pada klausul CREATE TABLE di atas.
-- Berikutnya menambahkan Foreign Key constraints dengan aturan referensial ON DELETE CASCADE ON UPDATE CASCADE:

-- 1. Foreign Key pada tabel dokter_admin
ALTER TABLE dokter_admin
    ADD CONSTRAINT fk_dokter_admin_dokter
        FOREIGN KEY (id_dokter) REFERENCES dokter(id_dokter)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_dokter_admin_admin
        FOREIGN KEY (id_admin) REFERENCES administrator(id_admin)
        ON DELETE CASCADE ON UPDATE CASCADE;

-- 2. Foreign Key pada tabel daftar
ALTER TABLE daftar
    ADD CONSTRAINT fk_daftar_pasien
        FOREIGN KEY (id_pasien) REFERENCES pasien(id_pasien)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_daftar_admin
        FOREIGN KEY (id_admin) REFERENCES administrator(id_admin)
        ON DELETE CASCADE ON UPDATE CASCADE;

-- 3. Foreign Key pada tabel pasien_dokter
ALTER TABLE pasien_dokter
    ADD CONSTRAINT fk_pasien_dokter_dokter
        FOREIGN KEY (id_dokter) REFERENCES dokter(id_dokter)
        ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_pasien_dokter_pasien
        FOREIGN KEY (id_pasien) REFERENCES pasien(id_pasien)
        ON DELETE CASCADE ON UPDATE CASCADE;

-- Verifikasi relasi foreign key yang terdaftar pada skema:
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    CONSTRAINT_NAME, 
    REFERENCED_TABLE_NAME, 
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'rumah_sakit'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- ----------------------------------------------------------------------------
-- LANGKAH 7: PENGGUNAAN INSERT
-- ----------------------------------------------------------------------------
-- Mengisi data pada tabel master (induk) terlebih dahulu:

-- Data administrator
INSERT INTO administrator (nama_admin, waktu_jaga) VALUES
('Siti Aminah', 'Senin-Jumat 08.00-16.00'),
('Ahmad Fauzi', 'Senin-Jumat 16.00-24.00'),
('Dewi Sartika', 'Sabtu-Minggu 08.00-20.00');

-- Data dokter
INSERT INTO dokter (nama_dokter, alamat_dokter, tanggal_lahir, no_hp, spesialis, waktu_kerja) VALUES
('Budi Harmoko', 'Jl. Melati No. 1 Jakarta', '1982-04-12', '081234567890', 'Umum', 'Senin-Rabu 09.00-14.00'),
('Indah Permata', 'Jl. Sudirman No. 45 Jakarta', '1988-09-20', '081298765432', 'Penyakit Dalam', 'Kamis-Sabtu 10.00-16.00'),
('Hendra Wijaya', 'Jl. Dahlia No. 12 Bogor', '1979-11-05', '081311223344', 'Anak', 'Senin-Jumat 08.00-12.00'),
('Siti Rahma', 'Jl. Mawar No. 7 Depok', '1990-01-15', '081377889900', 'Penyakit Dalam', 'Selasa-Kamis 13.00-18.00');

-- Data pasien
INSERT INTO pasien (nama_pasien, alamat_pasien, jenis_kelamin) VALUES
('Andi Pratama', 'Jl. Mawar No. 5 Bekasi', 1),
('Rina Marlina', 'Jl. Anggrek No. 10 Jakarta', 2),
('Bambang Pamungkas', 'Jl. Kenanga No. 8 Tangerang', 1),
('Siti Nurhaliza', 'Jl. Melati No. 3 Jakarta', 2),
('Dedi Kurniawan', 'Jl. Cendana No. 15 Bogor', 1);

-- Data transaksi / penghubung (tabel anak):
INSERT INTO dokter_admin (id_dokter, id_admin) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3);

INSERT INTO daftar (id_pasien, id_admin) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 3);

INSERT INTO pasien_dokter (id_dokter, id_pasien, waktu_periksa, resep) VALUES
(1, 1, '2026-10-10', 'RSP-001 Paracetamol 500mg, Amoxicillin'),
(2, 2, '2026-10-12', 'RSP-002 Omeprazole 20mg, Antasida'),
(3, 1, '2026-10-15', 'RSP-003 Vitamin C, Ibuprofen'),
(1, 3, '2026-10-18', 'RSP-004 Sirup Paracetamol, Cetirizine'),
(2, 4, '2026-10-20', 'RSP-005 Metformin 500mg'),
(4, 5, '2026-10-22', 'RSP-006 Ranitidine 150mg');

-- ----------------------------------------------------------------------------
-- LANGKAH 8: PENGGUNAAN SELECT
-- ----------------------------------------------------------------------------
-- Menampilkan seluruh data tabel dokter:
SELECT * FROM dokter;

-- Menampilkan kolom tertentu dari tabel pasien dengan alias:
SELECT 
    id_pasien AS 'ID Pasien', 
    nama_pasien AS 'Nama Lengkap Pasien', 
    alamat_pasien AS 'Alamat Domisili'
FROM pasien;

-- Menampilkan jadwal praktik dokter:
SELECT 
    nama_dokter AS 'Nama Dokter', 
    spesialis AS 'Spesialisasi', 
    waktu_kerja AS 'Jadwal Praktik'
FROM dokter;

-- ----------------------------------------------------------------------------
-- LANGKAH 9: PENGGUNAAN WHERE
-- ----------------------------------------------------------------------------
-- Filter dokter dengan spesialisasi Penyakit Dalam:
SELECT id_dokter, nama_dokter, spesialis, no_hp 
FROM dokter 
WHERE spesialis = 'Penyakit Dalam';

-- Filter pasien berjenis kelamin perempuan (2):
SELECT id_pasien, nama_pasien, alamat_pasien 
FROM pasien 
WHERE jenis_kelamin = 2;

-- Filter pasien_dokter dengan kondisi majemuk (AND):
SELECT id, id_dokter, id_pasien, waktu_periksa, resep
FROM pasien_dokter
WHERE id_dokter = 1 AND waktu_periksa >= '2026-10-12';

-- ----------------------------------------------------------------------------
-- LANGKAH 10: PENGGUNAAN JOIN
-- ----------------------------------------------------------------------------
-- A. INNER JOIN 2 Tabel (Pasien dan Pendaftaran melalui Administrator):
SELECT 
    d.id_daftar,
    p.nama_pasien,
    a.nama_admin,
    a.waktu_jaga
FROM daftar d
JOIN pasien p ON d.id_pasien = p.id_pasien
JOIN administrator a ON d.id_admin = a.id_admin;

-- B. INNER JOIN 3 Tabel (Pasien, Riwayat Periksa, dan Dokter Pemeriksa):
SELECT 
    pd.id AS no_pemeriksaan,
    p.nama_pasien,
    d.nama_dokter,
    d.spesialis,
    pd.waktu_periksa,
    pd.resep
FROM pasien_dokter pd
JOIN pasien p ON pd.id_pasien = p.id_pasien
JOIN dokter d ON pd.id_dokter = d.id_dokter;

-- C. LEFT JOIN (Seluruh dokter beserta data pemeriksaannya jika ada):
SELECT 
    d.nama_dokter,
    d.spesialis,
    COUNT(pd.id) AS total_pasien_diperiksa
FROM dokter d
LEFT JOIN pasien_dokter pd ON d.id_dokter = pd.id_dokter
GROUP BY d.id_dokter, d.nama_dokter, d.spesialis;

-- ----------------------------------------------------------------------------
-- LANGKAH 11: PENGGUNAAN FUNGSI MATEMATIKA
-- ----------------------------------------------------------------------------
-- Menghitung total entitas dengan COUNT():
SELECT 
    (SELECT COUNT(*) FROM dokter) AS total_dokter,
    (SELECT COUNT(*) FROM pasien) AS total_pasien,
    (SELECT COUNT(*) FROM administrator) AS total_admin,
    (SELECT COUNT(*) FROM pasien_dokter) AS total_pemeriksaan;

-- Menghitung rata-rata usia dokter menggunakan TIMESTAMPDIFF, AVG, dan ROUND:
SELECT 
    ROUND(AVG(TIMESTAMPDIFF(YEAR, tanggal_lahir, '2026-11-01')), 1) AS rata_rata_usia_dokter,
    MIN(tanggal_lahir) AS tgl_lahir_dokter_tertua,
    MAX(tanggal_lahir) AS tgl_lahir_dokter_termuda
FROM dokter;

-- ----------------------------------------------------------------------------
-- LANGKAH 12: PENGGUNAAN FUNGSI STRING
-- ----------------------------------------------------------------------------
-- CONCAT: Menggabungkan gelar dan spesialisasi dokter
SELECT 
    CONCAT('dr. ', nama_dokter, ' (Spesialis ', spesialis, ')') AS profil_dokter
FROM dokter;

-- UPPER & LOWER: Mengubah kapitalisasi nama dan alamat pasien
SELECT 
    UPPER(nama_pasien) AS nama_kapital,
    LOWER(alamat_pasien) AS alamat_huruf_kecil
FROM pasien;

-- LENGTH & SUBSTRING: Panjang nama pasien dan ekstraksi kode resep
SELECT 
    nama_pasien,
    LENGTH(nama_pasien) AS panjang_karakter_nama
FROM pasien;

SELECT 
    id,
    resep,
    SUBSTRING(resep, 1, 7) AS kode_resep,
    SUBSTRING(resep, 9) AS rincian_obat
FROM pasien_dokter;

-- ----------------------------------------------------------------------------
-- LANGKAH 13: PENGGUNAAN BETWEEN
-- ----------------------------------------------------------------------------
-- Filter rentang tanggal lahir dokter pada dekade 1980-an:
SELECT nama_dokter, spesialis, tanggal_lahir 
FROM dokter 
WHERE tanggal_lahir BETWEEN '1980-01-01' AND '1989-12-31';

-- Filter rentang tanggal periksa pasien antara 10 Oktober s.d. 18 Oktober 2026:
SELECT id, id_pasien, waktu_periksa, resep 
FROM pasien_dokter 
WHERE waktu_periksa BETWEEN '2026-10-10' AND '2026-10-18';

-- Filter rentang ID pasien antara 2 sampai 4:
SELECT id_pasien, nama_pasien, alamat_pasien 
FROM pasien 
WHERE id_pasien BETWEEN 2 AND 4;

-- ----------------------------------------------------------------------------
-- LANGKAH 14: PENGGUNAAN LIKE
-- ----------------------------------------------------------------------------
-- Pencarian awalan (nama pasien berawalan huruf 'S'):
SELECT id_pasien, nama_pasien, alamat_pasien 
FROM pasien 
WHERE nama_pasien LIKE 'S%';

-- Pencarian akhiran (nama dokter berakhiran kata 'Wijaya'):
SELECT id_dokter, nama_dokter, spesialis 
FROM dokter 
WHERE nama_dokter LIKE '%Wijaya';

-- Pencarian pola di tengah (alamat yang mengandung kata 'Jakarta'):
SELECT id_dokter, nama_dokter, alamat_dokter 
FROM dokter 
WHERE alamat_dokter LIKE '%Jakarta%';

-- ----------------------------------------------------------------------------
-- LANGKAH 15: PENGGUNAAN ORDER BY
-- ----------------------------------------------------------------------------
-- Pengurutan Ascending (A-Z) berdasarkan nama pasien:
SELECT id_pasien, nama_pasien, alamat_pasien 
FROM pasien 
ORDER BY nama_pasien ASC;

-- Pengurutan Descending (terbaru ke terlama) berdasarkan tanggal lahir dokter:
SELECT nama_dokter, tanggal_lahir, spesialis 
FROM dokter 
ORDER BY tanggal_lahir DESC;

-- Pengurutan multi-kolom (waktu periksa terbaru, lalu id_dokter):
SELECT id, waktu_periksa, id_dokter, id_pasien, resep 
FROM pasien_dokter 
ORDER BY waktu_periksa DESC, id_dokter ASC;

-- ----------------------------------------------------------------------------
-- LANGKAH 16: PENGGUNAAN GROUP BY
-- ----------------------------------------------------------------------------
-- Menghitung agregasi jumlah pasien berdasarkan jenis kelamin:
SELECT 
    CASE jenis_kelamin 
        WHEN 1 THEN 'Laki-laki' 
        WHEN 2 THEN 'Perempuan' 
    END AS kategori_jenis_kelamin,
    COUNT(*) AS jumlah_pasien
FROM pasien 
GROUP BY jenis_kelamin;

-- Menghitung jumlah resep/pemeriksaan yang ditangani tiap dokter:
SELECT 
    d.nama_dokter, 
    d.spesialis, 
    COUNT(pd.id) AS jumlah_pemeriksaan
FROM dokter d
LEFT JOIN pasien_dokter pd ON d.id_dokter = pd.id_dokter
GROUP BY d.id_dokter, d.nama_dokter, d.spesialis;

-- GROUP BY dengan klausul HAVING (dokter yang telah memeriksa minimal 2 pasien):
SELECT 
    d.nama_dokter, 
    COUNT(pd.id) AS total_pemeriksaan
FROM dokter d
JOIN pasien_dokter pd ON d.id_dokter = pd.id_dokter
GROUP BY d.id_dokter, d.nama_dokter
HAVING COUNT(pd.id) >= 2;

-- ----------------------------------------------------------------------------
-- LANGKAH 17: PENGGUNAAN UPDATE
-- ----------------------------------------------------------------------------
-- Memperbarui kontak dan jam kerja dokter spesialis (id_dokter = 1):
UPDATE dokter 
SET no_hp = '081299998888', 
    waktu_kerja = 'Senin-Jumat 08.00-15.00' 
WHERE id_dokter = 1;

-- Verifikasi perubahan data dokter:
SELECT id_dokter, nama_dokter, no_hp, waktu_kerja 
FROM dokter 
WHERE id_dokter = 1;

-- Memperbarui alamat pasien yang pindah domisili (id_pasien = 1):
UPDATE pasien 
SET alamat_pasien = 'Jl. Boulevard Raya No. 88 Bekasi Barat' 
WHERE id_pasien = 1;

-- Verifikasi perubahan data pasien:
SELECT id_pasien, nama_pasien, alamat_pasien 
FROM pasien 
WHERE id_pasien = 1;

-- Memperbarui resep obat pada catatan pemeriksaan (id = 1):
UPDATE pasien_dokter 
SET resep = 'RSP-001 Paracetamol 500mg, Amoxicillin 500mg, Vitamin B Complex' 
WHERE id = 1;

-- Verifikasi perubahan resep:
SELECT id, id_pasien, waktu_periksa, resep 
FROM pasien_dokter 
WHERE id = 1;

-- ============================================================================
-- AKHIR SKRIP PRAKTIKUM BASIS DATA TUGAS 2
-- ============================================================================
