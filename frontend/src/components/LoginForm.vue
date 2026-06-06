<template>
    <div class="auth-container">
        <div class="auth-card">
            <h2>Login</h2>
            <form @submit.prevent="handleLogin">
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" v-model="form.email" required placeholder="Masukkan Email">
                </div>
                
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" v-model="form.password" required placeholder="Masukkan Password">
                </div>
                
                <button type="submit" :disabled="loading" class="btn-primary">
                    {{ loading ? 'Loading...' : 'Login' }}
                </button>
            </form>
        </div>
    </div>
</template>

<script>
import { mapActions } from 'vuex';
import Swal from 'sweetalert2';

export default {
    name: 'LoginForm',
    data() {
        return {
            form: {
                email: '',
                password: ''
            },
            loading: false
        };
    },
    methods: {
        ...mapActions(['login']),
        async handleLogin() {
            this.loading = true;
            try {
                const result = await this.login(this.form);
                if (result.success) {
                    Swal.fire('Success!', 'Login successful', 'success');
                    this.$router.push('/');
                } else {
                    Swal.fire('Error!', result.error, 'error');
                }
            } catch (error) {
                const message =
                    error.response?.data?.message ||
                    error.response?.data?.error ||
                    'Terjadi kesalahan saat login';

                Swal.fire({
                    icon: 'error',
                    title: 'Login Gagal',
                    text: message
                });
            } finally {
                this.loading = false;
            }
        }
    }
};
</script>

<style lang="scss" scoped>
    .auth-container {
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: calc(100vh - 100px);
    }

    .auth-card {
        background: white;
        padding: 2rem;
        border-radius: 10px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        width: 100%;
        max-width: 400px;
    
        h2 {
            text-align: center;
            margin-bottom: 2rem;
            color: #333;
        }
    
        .form-group {
            margin-bottom: 1rem;
            
            label {
                display: block;
                margin-bottom: 0.5rem;
                color: #555;
            }
            
            input {
                width: 100%;
                padding: 0.75rem;
                border: 1px solid #ddd;
                border-radius: 5px;
                font-size: 1rem;
                
                &:focus {
                    outline: none;
                    border-color: #667eea;
                }
            }
        }
    
        .btn-primary {
            width: 100%;
            padding: 0.75rem;
            background: blue;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 1rem;
            cursor: pointer;
            transition: transform 0.2s;
            
            &:hover:not(:disabled) {
                transform: translateY(-2px);
            }
            
            &:disabled {
                opacity: 0.7;
                cursor: not-allowed;
            }
        }
        
        .auth-link {
            text-align: center;
            margin-top: 1rem;
            
            a {
                color: #667eea;
                text-decoration: none;
            }
        }
    }
</style>