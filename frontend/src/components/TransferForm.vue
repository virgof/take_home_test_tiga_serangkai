<template>
    <div class="transfer-form">
        <form @submit.prevent="handleTransfer">
            <div class="form-group">
                <label>Email Penerima</label>
                <input type="email" v-model="form.recipient_email" required placeholder="email@example.com" :class="{ 'is-invalid': errors.recipient_email }">
                <span v-if="errors.recipient_email" class="error-text">{{ errors.recipient_email }}</span>
            </div>
            
            <div class="form-group">
                <label>Nominal Transfer</label>
                <input type="number" v-model="form.amount" required min="0.01" step="0.01" placeholder="masukkan nominal" :class="{ 'is-invalid': errors.amount }">
                <span v-if="errors.amount" class="error-text">{{ errors.amount }}</span>
            </div>
            
            <div class="form-group">
                <label>Deskripsi (Opsional)</label>
                <textarea v-model="form.description" rows="2" placeholder="keterangan transfer"></textarea>
            </div>
            
            <button type="submit" :disabled="loading" class="btn-transfer">
                {{ loading ? 'Memproses...' : 'Transfer' }}
            </button>
        </form>
        
        <div v-if="currentBalance" class="info-balance">
            <strong>Saldo tersedia:</strong> {{ $options.filters.currency(currentBalance) }}
        </div>
    </div>
</template>

<script>
    import { mapGetters, mapActions } from 'vuex';

    export default {
        name: 'TransferForm',
        data() {
            return {
                form: {
                    recipient_email: '',
                    amount: '',
                    description: ''
                },
                errors: {
                    recipient_email: '',
                    amount: ''
                },
                loading: false
            };
        },
        computed: {
            ...mapGetters(['currentBalance', 'userEmail']) // Add userEmail getter
        },
        methods: {
            ...mapActions(['sendTransfer']),
            
            validateForm() {
                let isValid = true;
                this.errors = { recipient_email: '', amount: '' };
                
                if (!this.form.recipient_email) {
                    this.errors.recipient_email = 'Email penerima harus diisi';
                    isValid = false;
                } else if (!this.isValidEmail(this.form.recipient_email)) {
                    this.errors.recipient_email = 'Format email tidak valid';
                    isValid = false;
                } else if (this.form.recipient_email === this.userEmail) {
                    this.errors.recipient_email = 'Tidak dapat transfer ke akun sendiri';
                    isValid = false;
                }
                
                if (!this.form.amount) {
                    this.errors.amount = 'Nominal transfer harus diisi';
                    isValid = false;
                } else if (parseFloat(this.form.amount) <= 0) {
                    this.errors.amount = 'Nominal harus lebih besar dari 0';
                    isValid = false;
                } else if (parseFloat(this.form.amount) > this.currentBalance) {
                    this.errors.amount = 'Saldo tidak mencukupi';
                    isValid = false;
                }
                
                return isValid;
            },
            
            isValidEmail(email) {
                const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                return re.test(email);
            },
            
            async handleTransfer() {
                if (!this.validateForm()) {
                    return;
                }
                
                this.loading = true;
                try {
                    const result = await this.sendTransfer(this.form);
                    if (result.success) {
                        this.$swal({
                            icon: 'success',
                            title: 'Transfer Berhasil!',
                            html: `
                            <p>Transfer sebesar <strong>${this.formatCurrency(this.form.amount)}</strong></p>
                            <p>Kepada: <strong>${this.form.recipient_email}</strong></p>
                            <p>Saldo Anda sekarang: <strong>${this.$options.filters.currency(this.currentBalance - this.form.amount)}</strong></p>
                            `,
                            timer: 3000,
                            showConfirmButton: true
                        });
                        
                        this.$emit('transfer-success', result.data);
                        this.resetForm();
                    } else {
                        let errorMessage = result.error;
                        
                        if (errorMessage === 'Tidak dapat transfer ke akun sendiri') {
                            errorMessage = 'Tidak dapat transfer ke akun sendiri! Silakan gunakan email penerima yang berbeda.';
                            this.errors.recipient_email = errorMessage;
                        } else if (errorMessage === 'Saldo tidak mencukupi') {
                            errorMessage = 'Saldo Anda tidak mencukupi untuk melakukan transfer ini.';
                            this.errors.amount = errorMessage;
                        } else if (errorMessage === 'Penerima tidak ditemukan') {
                            errorMessage = 'Email penerima tidak terdaftar. Silakan cek kembali email tujuan.';
                            this.errors.recipient_email = errorMessage;
                        }
                        
                        this.$swal({
                            icon: 'error',
                            title: 'Transfer Gagal!',
                            text: errorMessage,
                            confirmButtonText: 'OK'
                        });
                    }
                } catch (error) {
                    this.$swal({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Terjadi kesalahan. Silakan coba lagi.',
                        confirmButtonText: 'OK'
                    });
                } finally {
                    this.loading = false;
                }
            },
            
            formatCurrency(value) {
                return `Rp${parseFloat(value).toLocaleString('id-ID')}`;
            },
            
            resetForm() {
                this.form = {
                    recipient_email: '',
                    amount: '',
                    description: ''
                };
                this.errors = {
                    recipient_email: '',
                    amount: ''
                };
            }
        }
    };
</script>

<style lang="scss" scoped>
    .transfer-form {
        .form-group {
            margin-bottom: 1rem;
            
            label {
                display: block;
                margin-bottom: 0.5rem;
                color: #555;
                font-size: 0.9rem;
                font-weight: 500;
            }
            
            input, textarea {
                width: 100%;
                padding: 0.75rem;
                border: 1px solid #ddd;
                border-radius: 5px;
                font-size: 0.9rem;
                transition: border-color 0.2s;
                
                &:focus {
                    outline: none;
                    border-color: #667eea;
                }
                
                &.is-invalid {
                    border-color: #dc3545;
                    background-color: #fff8f8;
                }
            }
            
            .error-text {
                display: block;
                margin-top: 0.25rem;
                font-size: 0.8rem;
                color: #dc3545;
            }
        }
        
        .btn-transfer {
            width: 100%;
            padding: 0.75rem;
            background: #28a745;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 1rem;
            cursor: pointer;
            transition: background 0.2s, transform 0.1s;
            
            &:hover:not(:disabled) {
                background: #218838;
            }
            
            &:active:not(:disabled) {
                transform: scale(0.98);
            }
            
            &:disabled {
                opacity: 0.7;
                cursor: not-allowed;
            }
        }
        
        .info-balance {
            margin-top: 1rem;
            padding: 0.75rem;
            background: #f8f9fa;
            border-radius: 5px;
            text-align: center;
            font-size: 0.9rem;
            color: #666;
            
            strong {
                color: #333;
            }
        }
    }
</style>