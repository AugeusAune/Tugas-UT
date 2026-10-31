-- 01_praktikum_transaksi.sql
-- Modul Praktikum Transaksi Basis Data (MSIM4206)
USE `rumah_sakit`;

-- 1. Verifikasi Tipe Storage Engine InnoDB
SHOW TABLE STATUS FROM `rumah_sakit` WHERE Name IN ('pasien', 'dokter', 'administrator');

-- 2. Transaksi 1 (Tanpa Commit)
DROP PROCEDURE IF EXISTS `transaksi1`;
DELIMITER $$
CREATE PROCEDURE `transaksi1`()
BEGIN
    START TRANSACTION;
    INSERT INTO `pasien` (`id_pasien`, `nama_pasien`, `alamat_pasien`, `jenis_kelamin`)
    VALUES (6, 'Tito', 'Jl Pakis haji no 25', 1);
    -- Transaksi sengaja tidak diakhiri COMMIT
END$$
DELIMITER ;

-- 3. Transaksi 2 (Dengan Commit)
DROP PROCEDURE IF EXISTS `transaksi2`;
DELIMITER $$
CREATE PROCEDURE `transaksi2`()
BEGIN
    START TRANSACTION;
    INSERT INTO `pasien` (`id_pasien`, `nama_pasien`, `alamat_pasien`, `jenis_kelamin`)
    VALUES (6, 'Tito', 'Jl Pakis haji no 25', 1);
    COMMIT;
END$$
DELIMITER ;

-- 4. Transaksi 3 (Rollback Sederhana)
DROP PROCEDURE IF EXISTS `transaksi3`;
DELIMITER $$
CREATE PROCEDURE `transaksi3`()
BEGIN
    START TRANSACTION;
    UPDATE `pasien` SET `nama_pasien` = 'Danar' WHERE `id_pasien` = 3;
    ROLLBACK;
END$$
DELIMITER ;

-- 5. Transaksi 4 (Rollback Insert dan Commit Update)
DROP PROCEDURE IF EXISTS `transaksi4`;
DELIMITER $$
CREATE PROCEDURE `transaksi4`()
BEGIN
    START TRANSACTION;
    INSERT INTO `pasien` (`id_pasien`, `nama_pasien`, `alamat_pasien`, `jenis_kelamin`)
    VALUES (7, 'Septin', 'Jl Anggrek no 5', 2);
    ROLLBACK;
    
    START TRANSACTION;
    UPDATE `pasien` SET `nama_pasien` = 'Septin' WHERE `id_pasien` = 3;
    COMMIT;
END$$
DELIMITER ;

-- 6. Transaksi 5 (Savepoint / Check Point)
DROP PROCEDURE IF EXISTS `transaksi5`;
DELIMITER $$
CREATE PROCEDURE `transaksi5`()
BEGIN
    START TRANSACTION;
    INSERT INTO `pasien` (`id_pasien`, `nama_pasien`, `alamat_pasien`, `jenis_kelamin`)
    VALUES (7, 'Dedi', 'Jl Melati no 1', 1);
    SAVEPOINT point1;
    
    INSERT INTO `pasien` (`id_pasien`, `nama_pasien`, `alamat_pasien`, `jenis_kelamin`)
    VALUES (8, 'Riko', 'Jl Mawar no 2', 1);
    ROLLBACK TO point1;
    
    INSERT INTO `pasien` (`id_pasien`, `nama_pasien`, `alamat_pasien`, `jenis_kelamin`)
    VALUES (9, 'Maya', 'Jl Melur no 3', 2);
    COMMIT;
END$$
DELIMITER ;
