new Vue({
  el: '#app',
  data: {
    pengirimanList: [
      { kode: 'REG', nama: 'JNE Regular' },
      { kode: 'EXP', nama: 'JNE Express' },
    ],
    paket: [
      {
        kode: 'PAKET-UT-001',
        nama: 'PAKET IPS Dasar',
        isi: ['EKMA4116', 'EKMA4115'],
        harga: 120000,
      },
      {
        kode: 'PAKET-UT-002',
        nama: 'PAKET IPA Dasar',
        isi: ['BIOL4201', 'FISIP4001'],
        harga: 140000,
      },
      {
        kode: 'PAKET-UT-003',
        nama: 'PAKET Komunikasi',
        isi: ['SKOM4101', 'SKOM4202'],
        harga: 110000,
      },
    ],
    tracking: {
      'DO2025-001': {
        nim: '041234567',
        nama: 'Ahmad Fauzi',
        status: 'Tiba di Tujuan',
        ekspedisi: 'JNE Express',
        tanggalKirim: '2025-05-10',
        paket: 'PAKET-UT-002',
        total: 140000,
        perjalanan: [
          {
            waktu: '2025-05-10 09:00',
            keterangan: 'Pesanan diproses di gudang pusat',
          },
          {
            waktu: '2025-05-10 15:30',
            keterangan: 'Paket diserahkan ke kurir',
          },
          {
            waktu: '2025-05-11 10:20',
            keterangan: 'Paket tiba di UPBJJ Surabaya',
          },
          {
            waktu: '2025-05-12 14:00',
            keterangan: 'Diterima oleh yang bersangkutan',
          },
        ],
      },
      'DO2025-002': {
        nim: '048765432',
        nama: 'Siti Aminah',
        status: 'Dalam Perjalanan',
        ekspedisi: 'JNE Regular',
        tanggalKirim: '2025-05-14',
        paket: 'PAKET-UT-001',
        total: 120000,
        perjalanan: [
          { waktu: '2025-05-14 08:00', keterangan: 'Pesanan diterima sistem' },
          { waktu: '2025-05-14 11:00', keterangan: 'Pengecekan stok selesai' },
          {
            waktu: '2025-05-14 16:45',
            keterangan: 'Paket keluar dari Hub Jakarta',
          },
        ],
      },
    },
    // State
    showModal: false,
    expandedDO: null,
    searchQuery: '',
    form: {
      nim: '',
      nama: '',
      ekspedisi: '',
      paketKode: '',
      tanggalKirim: new Date().toISOString().split('T')[0],
    },
  },
  computed: {
    nextDONumber() {
      const keys = Object.keys(this.tracking);
      const year = new Date().getFullYear();
      if (keys.length === 0) return `DO${year}-001`;

      const lastKey = keys.sort().pop();
      const lastNum = parseInt(lastKey.split('-')[1]);
      const nextNum = (lastNum + 1).toString().padStart(3, '0');
      return `DO${year}-${nextNum}`;
    },
    selectedPacket() {
      if (!this.form.paketKode) return null;
      return this.paket.find((p) => p.kode === this.form.paketKode);
    },
    filteredTracking() {
      if (!this.searchQuery) return this.tracking;
      const q = this.searchQuery.toLowerCase();
      const filtered = {};
      Object.keys(this.tracking).forEach((key) => {
        const item = this.tracking[key];
        if (
          key.toLowerCase().includes(q) ||
          item.nama.toLowerCase().includes(q) ||
          item.nim.toLowerCase().includes(q)
        ) {
          filtered[key] = item;
        }
      });
      return filtered;
    },
  },
  watch: {
    // Watcher 1: Watch modal state to clear form
    showModal(newVal) {
      if (newVal) {
        this.form.nim = '';
        this.form.nama = '';
        this.form.ekspedisi = '';
        this.form.paketKode = '';
      }
    },
    // Watcher 2: Watch selected packet to log to console (per requirement)
    'form.paketKode': function (newVal) {
      if (newVal) {
        console.log('User selecting packet:', newVal);
      }
    },
  },
  methods: {
    getStatusBadgeClass(status) {
      switch (status) {
        case 'Tiba di Tujuan': return 'pill-green';
        case 'Dalam Perjalanan': return 'pill-amber';
        case 'Diproses': return 'pill-blue';
        default: return 'pill-blue';
      }
    },
    getCardStatusClass(status) {
      switch (status) {
        case 'Tiba di Tujuan': return 'card-green';
        case 'Dalam Perjalanan': return 'card-amber';
        case 'Diproses': return 'card-blue';
        default: return 'card-blue';
      }
    },
    countStatus(status) {
      return Object.values(this.tracking).filter((t) => t.status === status)
        .length;
    },
    toggleExpand(doNum) {
      this.expandedDO = this.expandedDO === doNum ? null : doNum;
    },
    getPacketIsi(paketKode) {
      const p = this.paket.find((pk) => pk.kode === paketKode);
      return p ? p.isi : [];
    },
    closeModal() {
      this.showModal = false;
    },
    submitDO() {
      const newDO = this.nextDONumber;
      const packet = this.selectedPacket;

      // Simple validation
      if (!this.form.nim || !this.form.nama || !this.form.ekspedisi || !this.form.paketKode) {
        alert('Mohon lengkapi seluruh field (NIM, Nama, Ekspedisi, dan Paket).');
        return;
      }

      if (isNaN(this.form.nim)) {
        alert('NIM harus berupa angka.');
        return;
      }

      // Reactively add new tracking entry
      Vue.set(this.tracking, newDO, {
        nim: this.form.nim,
        nama: this.form.nama,
        status: 'Diproses',
        ekspedisi: this.form.ekspedisi,
        tanggalKirim: this.form.tanggalKirim,
        paket: this.form.paketKode,
        total: packet.harga,
        perjalanan: [
          {
            waktu: new Date().toLocaleString(),
            keterangan: 'Pesanan baru dibuat (Automated)',
          },
        ],
      });

      this.closeModal();
      alert(`DO Baru Berhasil Dibuat: ${newDO}`);
      this.expandedDO = newDO; // Auto expand the new DO
    },
    logout() {
      if (confirm('Apakah Anda yakin ingin keluar?')) {
        window.location.href = 'index.html';
      }
    },
  },
});
