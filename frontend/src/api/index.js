// src/api/index.js
import axios from 'axios';
import Swal from 'sweetalert2';

const API_URL = 'http://127.0.0.1:8000/api';

const api = axios.create({
    baseURL: API_URL,
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
});

api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('access_token');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response) {
            switch (error.response.status) {
                case 401:
                localStorage.removeItem('access_token');
                localStorage.removeItem('user');
                window.location.href = '/login';
                Swal.fire('Session Expired', 'Please login again', 'warning');
                break;
                case 429:
                Swal.fire('Too Many Attempts', 'Please try again later', 'warning');
                break;
                default:
                if (error.response.data.message) {
                    Swal.fire('Error', error.response.data.message, 'error');
                }
            }
        }
        return Promise.reject(error);
    }
);

export const auth = {
    register: (data) => api.post('/register', data),
    login: (data) => api.post('/login', data),
    logout: () => api.post('/logout'),
    refresh: () => api.post('/refresh'),
    getUser: () => api.get('/user')
};

export const dashboard = {
    getDashboard: () => api.get('/dashboard')
};

export const transfer = {
    send: (data) => api.post('/transfer', data)
};

export const transactions = {
    getHistory: (params) => api.get('/transactions', { params })
};

export default api;