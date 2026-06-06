import Vue from 'vue';
import App from './App.vue';
import router from './router';
import store from './store';
import VueSweetalert2 from 'vue-sweetalert2';
import 'sweetalert2/dist/sweetalert2.min.css';
import './assets/styles/main.scss';

Vue.use(VueSweetalert2);
Vue.config.productionTip = false;

Vue.filter('currency', (value) => {
  if (!value) return 'Rp0,00';
  return `Rp${parseFloat(value).toLocaleString('id-ID')}`;
});

Vue.filter('datetime', (value) => {
  if (!value) return '-';
  const date = new Date(value);
  return date.toLocaleString('id-ID');
});

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app');