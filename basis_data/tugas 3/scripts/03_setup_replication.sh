#!/usr/bin/env bash
# 03_setup_replication.sh
# Skrip otomatisasi konfigurasi replikasi MySQL Master ke Slave

set -e

echo "[1/5] Membuat user replikasi 'prodisi' pada Master..."
docker exec -i mysql_tugas3_master mysql -u root -proot -e "
CREATE USER IF NOT EXISTS 'prodisi'@'%' IDENTIFIED BY 'prodisi';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'prodisi'@'%';
FLUSH PRIVILEGES;
"

echo "[2/5] Membaca binary log status pada Master..."
BINLOG_STATUS=$(docker exec -i mysql_tugas3_master mysql -u root -proot -N -e "SHOW BINARY LOG STATUS;")
LOG_FILE=$(echo "$BINLOG_STATUS" | awk '{print $1}')
LOG_POS=$(echo "$BINLOG_STATUS" | awk '{print $2}')
echo "Master Log File: $LOG_FILE, Position: $LOG_POS"

echo "[3/5] Sinkronisasi basis data awal rumah_sakit ke Slave..."
docker exec mysql_tugas3_master mysqldump -u root -proot --databases rumah_sakit | docker exec -i mysql_tugas3_slave mysql -u root -proot

echo "[4/5] Mengonfigurasi dan mengaktifkan Replica pada Slave..."
docker exec -i mysql_tugas3_slave mysql -u root -proot -e "
STOP REPLICA;
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='mysql_master',
  SOURCE_USER='prodisi',
  SOURCE_PASSWORD='prodisi',
  SOURCE_PORT=3306,
  SOURCE_LOG_FILE='$LOG_FILE',
  SOURCE_LOG_POS=$LOG_POS,
  GET_SOURCE_PUBLIC_KEY=1;
START REPLICA;
"

echo "[5/5] Memeriksa status kesehatan replikasi pada Slave..."
docker exec -i mysql_tugas3_slave mysql -u root -proot -e "SHOW REPLICA STATUS\G" | grep -E "Replica_IO_Running|Replica_SQL_Running|Seconds_Behind_Source"

echo "=== Konfigurasi Replikasi Selesai & Berjalan Normal ==="
