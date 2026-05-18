new Vue({
  el: '#app',
  data: {
    upbjjList: ['Jakarta', 'Surabaya', 'Makassar', 'Padang', 'Denpasar'],
    kategoriList: ['MK Wajib', 'MK Pilihan', 'Praktikum', 'Problem-Based'],
    stok: [
      {
        kode: 'EKMA4116',
        judul: 'Pengantar Manajemen',
        kategori: 'MK Wajib',
        upbjj: 'Jakarta',
        lokasiRak: 'R1-A3',
        harga: 65000,
        qty: 28,
        safety: 20,
        catatanHTML: '<em>Edisi 2024, cetak ulang</em>',
      },
      {
        kode: 'EKMA4115',
        judul: 'Pengantar Akuntansi',
        kategori: 'MK Wajib',
        upbjj: 'Jakarta',
        lokasiRak: 'R1-A4',
        harga: 60000,
        qty: 7,
        safety: 15,
        catatanHTML: '<strong>Cover baru</strong>',
      },
      {
        kode: 'BIOL4201',
        judul: 'Biologi Umum (Praktikum)',
        kategori: 'Praktikum',
        upbjj: 'Surabaya',
        lokasiRak: 'R3-B2',
        harga: 80000,
        qty: 12,
        safety: 10,
        catatanHTML: 'Butuh <u>pendingin</u> untuk kit basah',
      },
      {
        kode: 'FISIP4001',
        judul: 'Dasar-Dasar Sosiologi',
        kategori: 'MK Pilihan',
        upbjj: 'Makassar',
        lokasiRak: 'R2-C1',
        harga: 55000,
        qty: 2,
        safety: 8,
        catatanHTML: 'Stok <i>menipis</i>, prioritaskan reorder',
      },
    ],
    // State
    showModal: false,
    isEdit: false,
    formData: {
      kode: '',
      judul: '',
      kategori: '',
      upbjj: '',
      lokasiRak: '',
      qty: 0,
      safety: 0,
      harga: 0,
      catatanHTML: '',
    },
    filters: {
      upbjj: '',
      kategori: '',
      lowStockOnly: false,
      search: '',
    },
    sortKey: 'judul',
    sortOrder: 'asc',
  },
  computed: {
    filteredStok() {
      let result = [...this.stok];

      // Filter: Search
      if (this.filters.search) {
        const s = this.filters.search.toLowerCase();
        result = result.filter(
          (item) =>
            item.judul.toLowerCase().includes(s) ||
            item.kode.toLowerCase().includes(s),
        );
      }

      // Filter: UPBJJ
      if (this.filters.upbjj) {
        result = result.filter((item) => item.upbjj === this.filters.upbjj);
      }

      // Filter: Kategori (Dependent on UPBJJ)
      if (this.filters.upbjj && this.filters.kategori) {
        result = result.filter(
          (item) => item.kategori === this.filters.kategori,
        );
      }

      // Filter: Low Stock (< Safety or 0)
      if (this.filters.lowStockOnly) {
        result = result.filter((item) => item.qty < item.safety || item.qty === 0);
      }

      // Sort
      result.sort((a, b) => {
        let valA = a[this.sortKey];
        let valB = b[this.sortKey];

        if (typeof valA === 'string') {
          valA = valA.toLowerCase();
          valB = valB.toLowerCase();
        }

        if (valA < valB) return this.sortOrder === 'asc' ? -1 : 1;
        if (valA > valB) return this.sortOrder === 'asc' ? 1 : -1;
        return 0;
      });

      return result;
    },
    countAman() {
      return this.stok.filter((item) => item.qty >= item.safety && item.qty > 0)
        .length;
    },
    countMenipis() {
      return this.stok.filter((item) => item.qty < item.safety && item.qty > 0)
        .length;
    },
    countKosong() {
      return this.stok.filter((item) => item.qty === 0).length;
    },
    totalStok() {
      return this.stok.reduce((acc, item) => acc + (item.qty || 0), 0);
    },
  },
  watch: {
    // Watcher 1: Reset kategori filter if upbjj is cleared
    'filters.upbjj': function (newVal) {
      if (!newVal) {
        this.filters.kategori = '';
      }
      console.log('UPBJJ filter changed to:', newVal || 'All');
    },
    // Watcher 2: Log search activity (or could be used for analytics/auto-save)
    stok: {
      handler(newVal) {
        console.log('Stock data updated. Current count:', newVal.length);
      },
      deep: true,
    },
  },
  methods: {
    sortBy(key) {
      if (this.sortKey === key) {
        this.sortOrder = this.sortOrder === 'asc' ? 'desc' : 'asc';
      } else {
        this.sortKey = key;
        this.sortOrder = 'asc';
      }
    },
    resetFilters() {
      this.filters.upbjj = '';
      this.filters.kategori = '';
      this.filters.lowStockOnly = false;
      this.filters.search = '';
    },
    openAddModal() {
      this.isEdit = false;
      this.formData = {
        kode: '',
        judul: '',
        kategori: '',
        upbjj: '',
        lokasiRak: '',
        qty: 0,
        safety: 10,
        harga: 0,
        catatanHTML: '',
      };
      this.showModal = true;
    },
    editItem(item) {
      this.isEdit = true;
      this.formData = { ...item };
      this.showModal = true;
    },
    closeModal() {
      this.showModal = false;
    },
    saveItem() {
      // Simple validation
      if (
        !this.formData.kode ||
        !this.formData.judul ||
        !this.formData.kategori ||
        !this.formData.upbjj ||
        !this.formData.lokasiRak
      ) {
        alert('Mohon lengkapi seluruh field wajib termasuk Lokasi Rak.');
        return;
      }

      if (this.formData.qty < 0 || this.formData.safety < 0) {
        alert('Jumlah stok dan safety tidak boleh negatif.');
        return;
      }

      if (this.isEdit) {
        // Update
        const index = this.stok.findIndex((i) => i.kode === this.formData.kode);
        if (index !== -1) {
          Vue.set(this.stok, index, { ...this.formData });
        }
      } else {
        // Add
        // Check duplicate kode
        if (this.stok.some((i) => i.kode === this.formData.kode)) {
          alert('Kode Mata Kuliah sudah ada!');
          return;
        }
        this.stok.push({ ...this.formData });
      }

      this.closeModal();
      alert(
        this.isEdit ? 'Data berhasil diperbarui!' : 'Data berhasil ditambahkan!',
      );
    },
    logout() {
      if (confirm('Apakah Anda yakin ingin keluar?')) {
        window.location.href = 'index.html';
      }
    },
  },
});
