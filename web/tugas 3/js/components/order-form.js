api.fetchTemplate('order-form').then(function (html) {
  Vue.component('order-form', {
    template: html,
    props: {
      paket: { type: Array, required: true },
      ekspedisi: { type: Array, required: true },
      autoDO: { type: String, default: '' }
    },
    data: function () {
      var today = new Date();
      var y = today.getFullYear();
      var m = String(today.getMonth() + 1).padStart(2, '0');
      var d = String(today.getDate()).padStart(2, '0');
      return {
        form: {
          nim: '',
          nama: '',
          ekspedisi: '',
          paketKode: '',
          tanggalKirim: y + '-' + m + '-' + d
        }
      };
    },
    computed: {
      selectedPacket: function () {
        if (!this.form.paketKode) return null;
        var self = this;
        return this.paket.find(function (p) { return p.kode === self.form.paketKode; });
      }
    },
    methods: {
      resetForm: function () {
        var today = new Date();
        var y = today.getFullYear();
        var m = String(today.getMonth() + 1).padStart(2, '0');
        var d = String(today.getDate()).padStart(2, '0');
        this.form.nim = '';
        this.form.nama = '';
        this.form.ekspedisi = '';
        this.form.paketKode = '';
        this.form.tanggalKirim = y + '-' + m + '-' + d;
      },
      submitOrder: function () {
        if (!this.form.nim || !this.form.nama || !this.form.ekspedisi || !this.form.paketKode) {
          alert('Mohon lengkapi seluruh field.');
          return;
        }
        if (isNaN(this.form.nim)) {
          alert('NIM harus berupa angka.');
          return;
        }
        this.$emit('created', {
          nim: this.form.nim,
          nama: this.form.nama,
          ekspedisi: this.form.ekspedisi,
          paketKode: this.form.paketKode,
          tanggalKirim: this.form.tanggalKirim
        });
        this.resetForm();
      }
    }
  });
});
