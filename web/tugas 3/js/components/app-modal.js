api.fetchTemplate('app-modal').then(function (html) {
  Vue.component('app-modal', {
    template: html,
    props: {
      title: { type: String, default: 'Modal' },
      visible: { type: Boolean, default: false }
    },
    methods: {
      close: function () {
        this.$emit('close');
      }
    }
  });
});
