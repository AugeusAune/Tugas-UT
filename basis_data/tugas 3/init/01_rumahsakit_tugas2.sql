-- Skema Basis Data rumah_sakit (Kelanjutan Tugas 2)
CREATE DATABASE IF NOT EXISTS `rumah_sakit`;
USE `rumah_sakit`;

-- 1. Tabel administrator
CREATE TABLE IF NOT EXISTS `administrator` (
  `id_admin` INT NOT NULL AUTO_INCREMENT,
  `nama_admin` VARCHAR(30) DEFAULT NULL,
  `waktu_jaga` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`id_admin`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Tabel dokter
CREATE TABLE IF NOT EXISTS `dokter` (
  `id_dokter` INT NOT NULL AUTO_INCREMENT,
  `nama_dokter` VARCHAR(30) DEFAULT NULL,
  `alamat_dokter` VARCHAR(100) DEFAULT NULL,
  `tanggal_lahir` DATE DEFAULT NULL,
  `no_hp` VARCHAR(15) DEFAULT NULL,
  `spesialis` VARCHAR(30) DEFAULT NULL,
  `waktu_kerja` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`id_dokter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Tabel pasien
CREATE TABLE IF NOT EXISTS `pasien` (
  `id_pasien` INT NOT NULL AUTO_INCREMENT,
  `nama_pasien` VARCHAR(30) DEFAULT NULL,
  `alamat_pasien` VARCHAR(100) DEFAULT NULL,
  `jenis_kelamin` INT DEFAULT NULL,
  PRIMARY KEY (`id_pasien`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Tabel dokter_admin
CREATE TABLE IF NOT EXISTS `dokter_admin` (
  `id_data` INT NOT NULL AUTO_INCREMENT,
  `id_dokter` INT DEFAULT NULL,
  `id_admin` INT DEFAULT NULL,
  PRIMARY KEY (`id_data`),
  KEY `fk_dokter_admin_dokter` (`id_dokter`),
  KEY `fk_dokter_admin_admin` (`id_admin`),
  CONSTRAINT `fk_dokter_admin_admin` FOREIGN KEY (`id_admin`) REFERENCES `administrator` (`id_admin`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_dokter_admin_dokter` FOREIGN KEY (`id_dokter`) REFERENCES `dokter` (`id_dokter`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Tabel pasien_dokter
CREATE TABLE IF NOT EXISTS `pasien_dokter` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_dokter` INT DEFAULT NULL,
  `id_pasien` INT DEFAULT NULL,
  `waktu_periksa` DATE DEFAULT NULL,
  `resep` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_pasien_dokter_dokter` (`id_dokter`),
  KEY `fk_pasien_dokter_pasien` (`id_pasien`),
  CONSTRAINT `fk_pasien_dokter_dokter` FOREIGN KEY (`id_dokter`) REFERENCES `dokter` (`id_dokter`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pasien_dokter_pasien` FOREIGN KEY (`id_pasien`) REFERENCES `pasien` (`id_pasien`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Tabel daftar
CREATE TABLE IF NOT EXISTS `daftar` (
  `id_daftar` INT NOT NULL AUTO_INCREMENT,
  `id_pasien` INT DEFAULT NULL,
  `id_admin` INT DEFAULT NULL,
  PRIMARY KEY (`id_daftar`),
  KEY `fk_daftar_pasien` (`id_pasien`),
  KEY `fk_daftar_admin` (`id_admin`),
  CONSTRAINT `fk_daftar_admin` FOREIGN KEY (`id_admin`) REFERENCES `administrator` (`id_admin`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_daftar_pasien` FOREIGN KEY (`id_pasien`) REFERENCES `pasien` (`id_pasien`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data Awal Praktikum
INSERT INTO `administrator` (`id_admin`, `nama_admin`, `waktu_jaga`) VALUES
(1, 'Siti Aminah', 'Senin-Jumat 08.00-16.00')
ON DUPLICATE KEY UPDATE `nama_admin` = VALUES(`nama_admin`);

INSERT INTO `dokter` (`id_dokter`, `nama_dokter`, `alamat_dokter`, `tanggal_lahir`, `no_hp`, `spesialis`, `waktu_kerja`) VALUES
(1, 'dr. Budi Harmoko', 'Jl. Melati No. 1 Jakarta', '1985-04-12', '081234567890', 'Umum', 'Senin-Rabu 09.00-14.00')
ON DUPLICATE KEY UPDATE `nama_dokter` = VALUES(`nama_dokter`);

INSERT INTO `pasien` (`id_pasien`, `nama_pasien`, `alamat_pasien`, `jenis_kelamin`) VALUES
(1, 'Andi Pratama', 'Jl. Mawar No. 5 Bekasi', 1),
(2, 'Siti Rahma', 'Jl. Anggrek No. 12 Jakarta', 2),
(3, 'Popi', 'Jl. Kenanga No. 10 Jakarta', 2),
(4, 'Rudi Hermawan', 'Jl. Cempaka No. 8 Depok', 1)
ON DUPLICATE KEY UPDATE `nama_pasien` = VALUES(`nama_pasien`);

INSERT INTO `dokter_admin` (`id_data`, `id_dokter`, `id_admin`) VALUES
(1, 1, 1)
ON DUPLICATE KEY UPDATE `id_dokter` = VALUES(`id_dokter`);

INSERT INTO `pasien_dokter` (`id`, `id_dokter`, `id_pasien`, `waktu_periksa`, `resep`) VALUES
(1, 1, 1, '2026-10-18', 'RSP0001')
ON DUPLICATE KEY UPDATE `resep` = VALUES(`resep`);

INSERT INTO `daftar` (`id_daftar`, `id_pasien`, `id_admin`) VALUES
(1, 1, 1)
ON DUPLICATE KEY UPDATE `id_pasien` = VALUES(`id_pasien`);
