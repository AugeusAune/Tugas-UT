-- 02_praktikum_trigger.sql
-- Modul Penambahan Tabel obat, transaksi_obat, dan Trigger tg_jual
USE `rumah_sakit`;

-- 1. Membuat Tabel obat
CREATE TABLE IF NOT EXISTS `obat` (
  `id_obat` INT(6) NOT NULL AUTO_INCREMENT,
  `kode_obat` VARCHAR(5) DEFAULT NULL,
  `nama_obat` VARCHAR(30) DEFAULT NULL,
  `harga` INT(10) DEFAULT NULL,
  `stok` INT(5) DEFAULT NULL,
  PRIMARY KEY (`id_obat`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Membuat Tabel transaksi_obat
CREATE TABLE IF NOT EXISTS `transaksi_obat` (
  `id_transaksi` INT(3) NOT NULL AUTO_INCREMENT,
  `id_pasien` INT(3) DEFAULT NULL,
  `id_obat` INT(3) DEFAULT NULL,
  `jumlah` INT(10) DEFAULT NULL,
  `total_harga` INT(10) DEFAULT NULL,
  PRIMARY KEY (`id_transaksi`),
  KEY `fk_transaksi_obat_pasien` (`id_pasien`),
  KEY `fk_transaksi_obat_obat` (`id_obat`),
  CONSTRAINT `fk_transaksi_obat_pasien` FOREIGN KEY (`id_pasien`) REFERENCES `pasien` (`id_pasien`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_transaksi_obat_obat` FOREIGN KEY (`id_obat`) REFERENCES `obat` (`id_obat`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Mengisi Data Awal Tabel obat
INSERT INTO `obat` (`id_obat`, `kode_obat`, `nama_obat`, `harga`, `stok`) VALUES
(1, 'A001', 'Amoxillin', 5000, 20),
(2, 'A002', 'Paracetamol', 3000, 50),
(3, 'A003', 'Antasida', 4000, 30)
ON DUPLICATE KEY UPDATE
  `nama_obat` = VALUES(`nama_obat`),
  `harga` = VALUES(`harga`),
  `stok` = VALUES(`stok`);

-- 4. Membuat Trigger tg_jual (Pengurangan Stok Otomatis)
DROP TRIGGER IF EXISTS `tg_jual`;
DELIMITER $$
CREATE TRIGGER `tg_jual`
AFTER INSERT ON `transaksi_obat`
FOR EACH ROW
BEGIN
  UPDATE `obat`
  SET `stok` = `stok` - NEW.`jumlah`
  WHERE `id_obat` = NEW.`id_obat`;
END$$
DELIMITER ;
