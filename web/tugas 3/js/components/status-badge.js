api.fetchTemplate('status-badge').then(function (html) {
  Vue.component('status-badge', {
    template: html,
    props: {
      qty: { type: Number, required: true },
      safety: { type: Number, required: true },
      catatanHTML: { type: String, default: '' }
    },
    data: function () {
      return { showTooltip: false };
    },
    computed: {
      label: function () {
        if (this.qty === 0) return 'Kosong';
        if (this.qty < this.safety) return 'Menipis';
        return 'Aman';
      },
      badgeClass: function () {
        if (this.qty === 0) return 'st-danger';
        if (this.qty < this.safety) return 'st-warning';
        return 'st-safe';
      }
    }
  });
});
