import Vue from 'vue';
import Vuex from 'vuex';
import { auth, dashboard, transfer, transactions } from '@/api';

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    user: JSON.parse(localStorage.getItem('user') || 'null'),
    token: localStorage.getItem('access_token') || null,
    balance: null,
    statistics: null,
    transactions: [],
    currentPage: 1,
    totalPages: 1,
    loading: false
  },
  
  mutations: {
    SET_USER(state, user) {
      state.user = user;
      localStorage.setItem('user', JSON.stringify(user));
    },
    SET_TOKEN(state, token) {
      state.token = token;
      localStorage.setItem('access_token', token);
    },
    CLEAR_AUTH(state) {
      state.user = null;
      state.token = null;
      state.balance = null;
      state.statistics = null;
      localStorage.removeItem('access_token');
      localStorage.removeItem('user');
    },
    SET_BALANCE(state, balance) {
      state.balance = balance;
    },
    SET_STATISTICS(state, statistics) {
      state.statistics = statistics;
    },
    SET_TRANSACTIONS(state, { data, current_page, last_page }) {
      state.transactions = data;
      state.currentPage = current_page;
      state.totalPages = last_page;
    },
    SET_LOADING(state, loading) {
      state.loading = loading;
    }
  },
  
  actions: {
    async register({ commit }, userData) {
      const response = await auth.register(userData);
      if (response.data.status === 'success') {
        const { access_token, user } = response.data.data;
        commit('SET_TOKEN', access_token);
        commit('SET_USER', user);
        return { success: true, data: response.data.data };
      }
      return { success: false, error: response.data.message };
    },
    
    async login({ commit }, credentials) {
      const response = await auth.login(credentials);
      if (response.data.status === 'success') {
        const { access_token, user } = response.data.data;
        commit('SET_TOKEN', access_token);
        commit('SET_USER', user);
        await this.dispatch('fetchDashboard');
        return { success: true, data: response.data.data };
      }
      return { success: false, error: response.data.message };
    },
    
    async logout({ commit }) {
      try {
        await auth.logout();
      } catch (error) {
        console.error('Logout error:', error);
      } finally {
        commit('CLEAR_AUTH');
      }
    },
    
    async fetchDashboard({ commit }) {
      commit('SET_LOADING', true);
      try {
        const response = await dashboard.getDashboard();
        if (response.data.status === 'success') {
          const { balance, statistics } = response.data.data;
          commit('SET_BALANCE', balance);
          commit('SET_STATISTICS', statistics);
          return { success: true, data: response.data.data };
        }
      } catch (error) {
        console.error('Dashboard error:', error);
        return { success: false, error: error.message };
      } finally {
        commit('SET_LOADING', false);
      }
    },
    
    async sendTransfer({ dispatch }, transferData) {
      const response = await transfer.send(transferData);
      if (response.data.status === 'success') {
        // Refresh dashboard setelah transfer
        await dispatch('fetchDashboard');
        return { success: true, data: response.data.data };
      }
      return { success: false, error: response.data.message };
    },
    
    async fetchTransactions({ commit }, params = {}) {
      commit('SET_LOADING', true);
      try {
        const response = await transactions.getHistory(params);
        if (response.data.status === 'success') {
          const { current_page, data, last_page } = response.data.data;
          commit('SET_TRANSACTIONS', { data, current_page, last_page });
          return { success: true, data: response.data.data };
        }
      } catch (error) {
        console.error('Transactions error:', error);
        return { success: false, error: error.message };
      } finally {
        commit('SET_LOADING', false);
      }
    }
  },
  
  getters: {
    isAuthenticated: (state) => !!state.token,
    userName: (state) => state.user?.name || '',
    userEmail: (state) => state.user?.email || '',
    formattedBalance: (state) => state.balance?.formatted || 'Rp0,00',
    currentBalance: (state) => state.balance?.raw || 0
  }
});