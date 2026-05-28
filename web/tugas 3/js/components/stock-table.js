api.fetchTemplate('stock-table').then(function (html) {
  Vue.component('ba-stock-table', {
    template: html,
    props: {
      items: { type: Array, required: true },
      upbjjList: { type: Array, required: true },
      kategoriList: { type: Array, required: true }
    },
    data: function () {
      return {
        filters: {
          search: '',
          upbjj: '',
          kategori: '',
          lowStock: false,
          outOfStock: false
        },
        sortKey: 'judul',
        sortAsc: true
      };
    },
    computed: {
      filteredItems: function () {
        var result = this.items.slice();
        if (this.filters.search) {
          var s = this.filters.search.toLowerCase();
          result = result.filter(function (item) {
            return item.kode.toLowerCase().includes(s) || item.judul.toLowerCase().includes(s);
          });
        }
        if (this.filters.upbjj) {
          result = result.filter(function (item) { return item.upbjj === this.filters.upbjj; }.bind(this));
        }
        if (this.filters.upbjj && this.filters.kategori) {
          result = result.filter(function (item) { return item.kategori === this.filters.kategori; }.bind(this));
        }
        if (this.filters.lowStock) {
          result = result.filter(function (item) { return item.qty < item.safety && item.qty > 0; });
        }
        if (this.filters.outOfStock) {
          result = result.filter(function (item) { return item.qty === 0; });
        }
        result.sort(function (a, b) {
          var valA = a[this.sortKey];
          var valB = b[this.sortKey];
          if (typeof valA === 'string') {
            valA = valA.toLowerCase();
            valB = valB.toLowerCase();
          }
          if (valA < valB) return this.sortAsc ? -1 : 1;
          if (valA > valB) return this.sortAsc ? 1 : -1;
          return 0;
        }.bind(this));
        return result;
      }
    },
    watch: {
      'filters.upbjj': function (newVal) {
        if (!newVal) this.filters.kategori = '';
      }
    },
    methods: {
      sortBy: function (key) {
        if (this.sortKey === key) {
          this.sortAsc = !this.sortAsc;
        } else {
          this.sortKey = key;
          this.sortAsc = true;
        }
      },
      resetFilter: function () {
        this.filters.search = '';
        this.filters.upbjj = '';
        this.filters.kategori = '';
        this.filters.lowStock = false;
        this.filters.outOfStock = false;
      },
      openAdd: function () {
        this.$emit('open-add');
      }
    }
  });
});
