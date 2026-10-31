# Technical Specification: Tugas 3 Basis Data (MSIM4206)

**Mata Kuliah:** MSIM4206 – Basis Data  
**Topik:** Praktikum Transaksi dan Basis Data Terdistribusi  
**Referensi:** [`USA_MSIM4206 - Tugas 3.pdf`](../Tugas%203.pdf) & [`panduan tugas 3.pdf`](../panduan%20tugas%203.pdf)  
**Status:** Approved Design Spec  

---

## 1. Latar Belakang & Keterkaitan Sistem

Praktikum Tugas 3 adalah kelanjutan langsung dari basis data **`rumahsakit`** yang telah dirancang dan diimplementasikan pada Tugas 2.

Pada Tugas 2, telah dibentuk 6 tabel relasional:
- `administrator` (PK: `id_admin`)
- `dokter` (PK: `id_dokter`)
- `pasien` (PK: `id_pasien`)
- `dokter_admin` (FK: `id_dokter`, `id_admin`)
- `pasien_dokter` (FK: `id_dokter`, `id_pasien`)
- `daftar` (FK: `id_pasien`, `id_admin`)

Pada Tugas 3, sistem diperluas untuk mengimplementasikan:
1. **Mekanisme Transaksi ACID** (`COMMIT`, `ROLLBACK`, `SAVEPOINT`) dengan verifikasi tipe *Storage Engine* InnoDB.
2. **Event Trigger Otomatisasi Stok** dengan menambahkan 2 tabel baru: `obat` dan `transaksi_obat`.
3. **Basis Data Terdistribusi** menggunakan **Replikasi MySQL Master–Slave** sesuai Bab B.2 panduan praktikum resmi UT.

---

## 2. Arsitektur Komponen & Environment

Sesuai panduan BMP/Panduan Praktikum UT, arsitektur basis data terdistribusi memerlukan 2 node MySQL yang saling terhubung:
- **Node 1 (Master):** Server sumber yang mencatat binary log dan memproses transaksi/perubahan data.
- **Node 2 (Slave / Replica):** Server target yang membaca relay log dari Master dan mereplikasi perubahan secara asinkron.

### Topologi Docker Compose
Untuk menghindari kebutuhan 2 mesin fisik terpisah (Windows & Ubuntu), topologi diisolasi dalam satu file `docker-compose.yml`:

```
+-----------------------------------+        +-----------------------------------+
|            NODE MASTER            |        |            NODE SLAVE             |
|  Container: mysql_tugas3_master   |        |  Container: mysql_tugas3_slave    |
|  Port Host: 3306                  |        |  Port Host: 3307                  |
|  Server ID: 1                     |=======>|  Server ID: 2                     |
|  Binary Log: mysql-bin            | (Sync) |  Relay Log: mysql-relay-bin       |
|  Binlog DB: rumahsakit            |        |  Read Only: 1                     |
+-----------------+-----------------+        +-----------------+-----------------+
                  |                                            |
                  v                                            v
+-----------------+-----------------+        +-----------------+-----------------+
| Container: pma_tugas3_master      |        | Container: pma_tugas3_slave       |
| phpMyAdmin Master (Port 8080)     |        | phpMyAdmin Slave (Port 8081)      |
+-----------------------------------+        +-----------------------------------+
```

---

## 3. Spesifikasi Skema & Relasi Basis Data Tambahan

### A. Tabel `obat`
Menyimpan katalog obat dan jumlah persediaan.

| Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id_obat` | `INT(6)` | Primary Key, `AUTO_INCREMENT` |
| `kode_obat` | `VARCHAR(5)` | Kode unik obat (misal: A001) |
| `nama_obat` | `VARCHAR(30)` | Nama komersial/generik obat |
| `harga` | `INT(10)` | Harga satuan obat |
| `stok` | `INT(5)` | Kuantitas stok aktif |

### B. Tabel `transaksi_obat`
Menyimpan histori transaksi pembelian obat oleh pasien.

| Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id_transaksi` | `INT(3)` | Primary Key, `AUTO_INCREMENT` |
| `id_pasien` | `INT(3)` | Foreign Key → `pasien(id_pasien)` (`ON DELETE CASCADE`) |
| `id_obat` | `INT(3)` | Foreign Key → `obat(id_obat)` (`ON DELETE CASCADE`) |
| `jumlah` | `INT(10)` | Kuantitas obat yang dibeli |
| `total_harga` | `INT(10)` | Kalkulasi `jumlah * harga` |

---

## 4. Spesifikasi Kontrol Transaksi & Trigger

### A. Kontrol Transaksi (ACID)
1. **Storage Engine Verification:**
   Memastikan seluruh tabel bertipe `Engine=InnoDB` agar mendukung transaksi ACID.
2. **Uji Commit:**
   - Prosedur `transaksi1` (DML insert pasien ID 6 tanpa `COMMIT`) -> Verifikasi data tidak tersimpan permanen.
   - Prosedur `transaksi2` (DML insert pasien ID 6 dengan `COMMIT`) -> Verifikasi data tersimpan permanen.
3. **Uji Rollback:**
   - Transaksi update nama pasien `id_pasien=3` dari 'Popi' menjadi 'Danar', diikuti `ROLLBACK` -> Nilai tetap 'Popi'.
4. **Uji Savepoint:**
   - Pembuatan titik pemulihan parsial `SAVEPOINT sp1;` dan pengembalian kondisi dengan `ROLLBACK TO sp1;`.

### B. Trigger `tg_jual`
- **Event:** `AFTER INSERT ON transaksi_obat`
- **Granularitas:** `FOR EACH ROW`
- **Aksi:**
  ```sql
  UPDATE obat
  SET stok = stok - NEW.jumlah
  WHERE id_obat = NEW.id_obat;
  ```
- **Kondisi Uji:**
  - Stok awal obat Amoxillin: 20 unit.
  - Pasien membeli: 5 unit.
  - Hasil akhir yang diharapkan: Stok berkurang otomatis menjadi 15 unit.

---

## 5. Spesifikasi Konfigurasi Replikasi Master–Slave

### A. Konfigurasi Server
- **Master (`master.cnf`):**
  ```ini
  [mysqld]
  server-id=1
  log-bin=mysql-bin
  binlog-format=ROW
  binlog-do-db=rumahsakit
  ```
- **Slave (`slave.cnf`):**
  ```ini
  [mysqld]
  server-id=2
  relay-log=mysql-relay-bin
  read-only=1
  ```

### B. Kredensial User Replikasi
- **User:** `prodisi`
- **Host:** `%`
- **Password:** `prodisi`
- **Privileges:** `REPLICATION SLAVE`, `REPLICATION CLIENT`

### C. Kriteria Keberhasilan Replikasi
1. Query `SHOW SLAVE STATUS\G`:
   - `Slave_IO_Running = Yes`
   - `Slave_SQL_Running = Yes`
   - `Seconds_Behind_Master = 0`
2. Uji DML Nyata:
   - Tambah record obat baru di Master (misal: Obat "Demam", kode "A005", stok 100).
   - Record tersebut langsung terbaca pada query `SELECT` di server Slave.

---

## 6. Format Luaran & Standar Laporan

1. **Struktur Direktori Proyek:**
   - Folder rencana: `basis_data/tugas 3/plans/`
   - Folder artefak cetak & aset visual: `basis_data/tugas 3/artifacts/`
   - Folder laporan final: `basis_data/tugas 3/reports/` (berisi 1 file `.docx` dan 1 file `.pdf`).
2. **Konten Wajib Laporan:**
   - Identitas Mahasiswa (Nama: Farhan Aditya, NIM: 054750333, Prodi: Sistem Informasi).
   - Analisis & Penjelasan Teori.
   - Langkah Praktik Transaksi & Trigger (disertai potongan kode dan screenshot).
   - Langkah Praktik Replikasi Master-Slave (konfigurasi, status thread, dan pengujian sinkronisasi data).
   - Kesimpulan teknis & Penutup.
