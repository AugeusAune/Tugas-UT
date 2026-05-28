Vue.filter('currency', function (value) {
  if (!value && value !== 0) return '';
  return 'Rp ' + Number(value).toLocaleString('id-ID');
});

Vue.filter('satuan', function (value) {
  if (value === undefined || value === null) return '';
  return Number(value).toLocaleString('id-ID') + ' buah';
});

Vue.filter('formatDate', function (value) {
  if (!value) return '';
  var parts = value.split('-');
  var months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
  return parseInt(parts[2]) + ' ' + months[parseInt(parts[1]) - 1] + ' ' + parts[0];
});

new Vue({
  el: '#app',
  data: {
    tab: 'stok',
    upbjjList: [],
    kategoriList: [],
    pengirimanList: [],
    paket: [],
    stok: [],
    tracking: {},
    showModal: false,
    isEdit: false,
    formData: {
      kode: '', judul: '', kategori: '', upbjj: '', lokasiRak: '',
      qty: 0, safety: 0, harga: 0, catatanHTML: ''
    },
    sortKey: 'judul',
    sortAsc: true
  },
  computed: {
    nextDONumber: function () {
      var keys = Object.keys(this.tracking);
      var year = new Date().getFullYear();
      if (keys.length === 0) return 'DO' + year + '-001';
      var lastKey = keys.sort().pop();
      var lastNum = parseInt(lastKey.split('-')[1]);
      var nextNum = (lastNum + 1).toString().padStart(3, '0');
      return 'DO' + year + '-' + nextNum;
    }
  },
  watch: {
    'tab': function (newVal) {
      console.log('Tab changed to:', newVal);
    }
  },
  methods: {
    handleNewDO: function (form) {
      var newDO = this.nextDONumber;
      var packet = this.paket.find(function (p) { return p.kode === form.paketKode; });
      Vue.set(this.tracking, newDO, {
        nim: form.nim,
        nama: form.nama,
        status: 'Diproses',
        ekspedisi: form.ekspedisi,
        tanggalKirim: form.tanggalKirim,
        paket: form.paketKode,
        total: packet ? packet.harga : 0,
        perjalanan: [{
          waktu: new Date().toLocaleString('id-ID'),
          keterangan: 'Pesanan baru dibuat'
        }]
      });
      alert('DO Baru Berhasil Dibuat: ' + newDO);
    },
    openAdd: function () {
      this.isEdit = false;
      this.formData = {
        kode: '', judul: '', kategori: '', upbjj: '', lokasiRak: '',
        qty: 0, safety: 10, harga: 0, catatanHTML: ''
      };
      this.showModal = true;
    },
    editItem: function (item) {
      this.isEdit = true;
      this.formData = JSON.parse(JSON.stringify(item));
      this.showModal = true;
    },
    deleteItem: function (item) {
      if (!confirm('Yakin ingin menghapus ' + item.kode + ' - ' + item.judul + '?')) return;
      var idx = this.stok.findIndex(function (i) { return i.kode === item.kode; });
      if (idx !== -1) this.stok.splice(idx, 1);
    },
    saveEdit: function () {
      if (!this.formData.kode || !this.formData.judul || !this.formData.kategori ||
          !this.formData.upbjj || !this.formData.lokasiRak) {
        alert('Mohon lengkapi seluruh field wajib.');
        return;
      }
      if (this.formData.qty < 0 || this.formData.safety < 0) {
        alert('Stok dan safety tidak boleh negatif.');
        return;
      }
      if (this.isEdit) {
        var idx = this.stok.findIndex(function (i) { return i.kode === this.formData.kode; }.bind(this));
        if (idx !== -1) Vue.set(this.stok, idx, JSON.parse(JSON.stringify(this.formData)));
      } else {
        if (this.stok.some(function (i) { return i.kode === this.formData.kode; }.bind(this))) {
          alert('Kode Mata Kuliah sudah ada!');
          return;
        }
        this.stok.push(JSON.parse(JSON.stringify(this.formData)));
      }
      this.showModal = false;
    },
    closeModal: function () {
      this.showModal = false;
    },
    resetFilter: function () {
      this.$refs.stockTable && this.$refs.stockTable.resetFilter();
    }
  },
  mounted: function () {
    var self = this;
    api.fetchData().then(function (data) {
      self.upbjjList = data.upbjjList;
      self.kategoriList = data.kategoriList;
      self.pengirimanList = data.pengirimanList;
      self.paket = data.paket;
      self.stok = data.stok;
      self.tracking = data.tracking;
    }).catch(function (err) {
      console.error('Failed to load data:', err);
    });
  }
});
