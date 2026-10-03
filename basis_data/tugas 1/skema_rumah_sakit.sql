-- ============================================================================
-- TUGAS 1 BASIS DATA (MSIM4206) - UNIVERSITAS TERBUKA
-- SKEMA BASIS DATA RUMAH SAKIT
-- Kasus: Dokter, Pasien, Administrasi, Pemeriksaan, dan Resep Obat
-- ============================================================================

CREATE DATABASE IF NOT EXISTS rumah_sakit_db;
USE rumah_sakit_db;

-- 1. TABEL DOKTER
CREATE TABLE IF NOT EXISTS dokter (
    id_dokter VARCHAR(10) PRIMARY KEY,
    nama_dokter VARCHAR(100) NOT NULL,
    spesialisasi VARCHAR(50) NOT NULL,
    no_telepon VARCHAR(20) NOT NULL,
    jadwal_praktek VARCHAR(100) NOT NULL
);

-- 2. TABEL PETUGAS ADMINISTRASI
CREATE TABLE IF NOT EXISTS petugas_administrasi (
    id_petugas VARCHAR(10) PRIMARY KEY,
    nama_petugas VARCHAR(100) NOT NULL,
    shift VARCHAR(20) NOT NULL
);

-- 3. TABEL PASIEN
CREATE TABLE IF NOT EXISTS pasien (
    id_pasien VARCHAR(10) PRIMARY KEY,
    nik VARCHAR(16) NOT NULL UNIQUE,
    nama_pasien VARCHAR(100) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    jenis_kelamin ENUM('L', 'P') NOT NULL,
    alamat TEXT NOT NULL,
    no_telepon VARCHAR(20) NOT NULL
);

-- 4. TABEL PENDAFTARAN (Relasi Pasien mendaftar melalui Bagian Administrasi)
CREATE TABLE IF NOT EXISTS pendaftaran (
    id_pendaftaran VARCHAR(10) PRIMARY KEY,
    id_pasien VARCHAR(10) NOT NULL,
    id_petugas VARCHAR(10) NOT NULL,
    tanggal_daftar DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    keluhan_awal TEXT NOT NULL,
    CONSTRAINT fk_pendaftaran_pasien FOREIGN KEY (id_pasien) 
        REFERENCES pasien(id_pasien) ON DELETE CASCADE,
    CONSTRAINT fk_pendaftaran_petugas FOREIGN KEY (id_petugas) 
        REFERENCES petugas_administrasi(id_petugas) ON DELETE RESTRICT
);

-- 5. TABEL PEMERIKSAAN (Entitas Asosiatif: Menangani relasi Many-to-Many Dokter & Pasien)
CREATE TABLE IF NOT EXISTS pemeriksaan (
    id_pemeriksaan VARCHAR(10) PRIMARY KEY,
    id_pendaftaran VARCHAR(10) NOT NULL,
    id_dokter VARCHAR(10) NOT NULL,
    tanggal_pemeriksaan DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diagnosa TEXT NOT NULL,
    tindakan TEXT,
    catatan_dokter TEXT,
    CONSTRAINT fk_pemeriksaan_pendaftaran FOREIGN KEY (id_pendaftaran) 
        REFERENCES pendaftaran(id_pendaftaran) ON DELETE CASCADE,
    CONSTRAINT fk_pemeriksaan_dokter FOREIGN KEY (id_dokter) 
        REFERENCES dokter(id_dokter) ON DELETE RESTRICT
);

-- 6. TABEL RESEP (Dibuat oleh Dokter setelah pemeriksaan)
CREATE TABLE IF NOT EXISTS resep (
    id_resep VARCHAR(10) PRIMARY KEY,
    id_pemeriksaan VARCHAR(10) NOT NULL UNIQUE,
    tanggal_resep DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    catatan_resep TEXT,
    CONSTRAINT fk_resep_pemeriksaan FOREIGN KEY (id_pemeriksaan) 
        REFERENCES pemeriksaan(id_pemeriksaan) ON DELETE CASCADE
);

-- 7. TABEL MASTER OBAT
CREATE TABLE IF NOT EXISTS obat (
    id_obat VARCHAR(10) PRIMARY KEY,
    nama_obat VARCHAR(100) NOT NULL,
    jenis_obat VARCHAR(50) NOT NULL,
    stok INT NOT NULL DEFAULT 0,
    harga DECIMAL(12, 2) NOT NULL
);

-- 8. TABEL DETAIL RESEP (Entitas Asosiatif: Relasi Many-to-Many antara Resep dan Obat)
CREATE TABLE IF NOT EXISTS detail_resep (
    id_detail_resep INT AUTO_INCREMENT PRIMARY KEY,
    id_resep VARCHAR(10) NOT NULL,
    id_obat VARCHAR(10) NOT NULL,
    jumlah INT NOT NULL,
    aturan_pakai VARCHAR(100) NOT NULL,
    CONSTRAINT fk_detail_resep FOREIGN KEY (id_resep) 
        REFERENCES resep(id_resep) ON DELETE CASCADE,
    CONSTRAINT fk_detail_obat FOREIGN KEY (id_obat) 
        REFERENCES obat(id_obat) ON DELETE RESTRICT
);

-- ============================================================================
-- DATA CONTOH (DUMMY DATA) UNTUK PENGUJIAN PRAKTIKUM
-- ============================================================================

INSERT INTO dokter (id_dokter, nama_dokter, spesialisasi, no_telepon, jadwal_praktek) VALUES
('DOC001', 'dr. Budi Santoso, Sp.PD', 'Penyakit Dalam', '081234567890', 'Senin - Rabu, 08:00 - 12:00'),
('DOC002', 'dr. Siti Rahma, Sp.JP', 'Jantung', '081234567891', 'Kamis - Sabtu, 09:00 - 13:00');

INSERT INTO petugas_administrasi (id_petugas, nama_petugas, shift) VALUES
('ADM001', 'Ahmad Fadli', 'Pagi'),
('ADM002', 'Dewi Lestari', 'Siang');

INSERT INTO pasien (id_pasien, nik, nama_pasien, tanggal_lahir, jenis_kelamin, alamat, no_telepon) VALUES
('PAS001', '3201010101900001', 'Rian Pratama', '1990-05-12', 'L', 'Jl. Kenanga No. 10 Jakarta', '085712345678'),
('PAS002', '3201010202950002', 'Nur Aini', '1995-08-24', 'P', 'Jl. Melati No. 5 Jakarta', '085712345679');

INSERT INTO pendaftaran (id_pendaftaran, id_pasien, id_petugas, tanggal_daftar, keluhan_awal) VALUES
('REG001', 'PAS001', 'ADM001', '2026-10-03 08:15:00', 'Demam tinggi dan nyeri perut'),
('REG002', 'PAS002', 'ADM001', '2026-10-03 08:30:00', 'Nyeri dada saat aktivitas berat');

INSERT INTO pemeriksaan (id_pemeriksaan, id_pendaftaran, id_dokter, tanggal_pemeriksaan, diagnosa, tindakan, catatan_dokter) VALUES
('EXM001', 'REG001', 'DOC001', '2026-10-03 09:00:00', 'Gastritis Akut', 'Pemberian antasida dan edukasi pola makan', 'Hindari makanan pedas dan asam'),
('EXM002', 'REG001', 'DOC002', '2026-10-03 10:00:00', 'Observasi Palpitasi', 'Pemeriksaan EKG', 'Hasil EKG dalam batas normal');

INSERT INTO resep (id_resep, id_pemeriksaan, tanggal_resep, catatan_resep) VALUES
('RSP001', 'EXM001', '2026-10-03 09:15:00', 'Diminum setelah makan');

INSERT INTO obat (id_obat, nama_obat, jenis_obat, stok, harga) VALUES
('MED001', 'Omeprazole 20mg', 'Kapsul', 150, 15000.00),
('MED002', 'Antasida Doen', 'Tablet Kunyah', 200, 5000.00),
('MED003', 'Paracetamol 500mg', 'Tablet', 300, 6000.00);

INSERT INTO detail_resep (id_resep, id_obat, jumlah, aturan_pakai) VALUES
('RSP001', 'MED001', 10, '1x sehari sebelum makan'),
('RSP001', 'MED002', 15, '3x sehari 1 tablet kunyah sebelum makan');
