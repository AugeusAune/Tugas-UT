api.fetchTemplate('do-tracking').then(function (html) {
  Vue.component('do-tracking', {
    template: html,
    props: {
      data: { type: Object, required: true }
    },
    data: function () {
      return {
        searchQuery: '',
        expandedDO: null,
        showStatusModal: false,
        statusDO: null,
        statusForm: { keterangan: '' }
      };
    },
    computed: {
      filteredData: function () {
        if (!this.searchQuery) return this.data;
        var q = this.searchQuery.toLowerCase();
        var filtered = {};
        var self = this;
        Object.keys(this.data).forEach(function (key) {
          var item = self.data[key];
          if (key.toLowerCase().includes(q) || item.nim.toLowerCase().includes(q)) {
            filtered[key] = item;
          }
        });
        return filtered;
      }
    },
    methods: {
      searchDO: function () {},
      clearSearch: function () {
        this.searchQuery = '';
      },
      statusClass: function (status) {
        switch (status) {
          case 'Tiba di Tujuan': return 'pill-green';
          case 'Dalam Perjalanan': return 'pill-amber';
          case 'Diproses': return 'pill-blue';
          default: return 'pill-blue';
        }
      },
      toggleExpand: function (doNum) {
        this.expandedDO = this.expandedDO === doNum ? null : doNum;
      },
      openAddStatus: function (doNum) {
        this.statusDO = doNum;
        this.statusForm.keterangan = '';
        this.showStatusModal = true;
      },
      closeStatusModal: function () {
        this.showStatusModal = false;
        this.statusDO = null;
      },
      submitStatus: function () {
        if (!this.statusForm.keterangan) {
          alert('Keterangan tidak boleh kosong.');
          return;
        }
        var now = new Date();
        var waktu = now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0') + '-' + String(now.getDate()).padStart(2, '0') + ' ' + String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');
        this.data[this.statusDO].perjalanan.push({
          waktu: waktu,
          keterangan: this.statusForm.keterangan
        });
        this.data[this.statusDO].status = 'Dalam Perjalanan';
        this.closeStatusModal();
      }
    }
  });
});
