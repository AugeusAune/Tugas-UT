var api = {
  fetchData: function () {
    return fetch('data/dataBahanAjar.json').then(function (r) { return r.json(); });
  },
  fetchTemplate: function (name) {
    return fetch('templates/' + name + '.html').then(function (r) { return r.text(); });
  }
};
