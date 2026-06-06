<template>
    <div class="dashboard-container">
        <div class="container">
            <div class="welcome-card">
                <h1>Selamat datang, {{ userName }}</h1>
                <div class="balance-card">
                    <div class="balance-label">Saldo Anda:</div>
                    <div class="balance-amount">{{ formattedBalance }}</div>
                </div>
            </div>
            
            <div class="dashboard-grid">
                <div class="card">
                    <h3>Transfer Dana</h3>
                    <TransferForm @transfer-success="onTransferSuccess" />
                </div>
                
                <div class="card">
                    <h3>Statistik</h3>
                    <div class="statistics" v-if="statistics">
                        <div class="stat-item">
                            <span class="stat-label">Total Transaksi:</span>
                            <span class="stat-value">{{ statistics.total_transactions }}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">Total Terkirim:</span>
                            <span class="stat-value text-danger">{{ statistics.total_sent }}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">Total Diterima:</span>
                            <span class="stat-value text-success">{{ statistics.total_received }}</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-label">Member Sejak:</span>
                            <span class="stat-value">{{ statistics.member_since }}</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="card full-width">
                <h3>Riwayat Transaksi</h3>
                <TransactionList />
            </div>
        </div>
    </div>
</template>

<script>
    import { mapGetters, mapActions } from 'vuex';
    import TransferForm from './TransferForm.vue';
    import TransactionList from './TransactionList.vue';
    import Swal from 'sweetalert2';

    export default {
        name: 'UserDashboard',
        components: {
            TransferForm,
            TransactionList
        },
        computed: {
            ...mapGetters(['userName', 'formattedBalance']),
            statistics() {
            return this.$store.state.statistics;
            }
        },
        mounted() {
            this.loadDashboard();
        },
        methods: {
            ...mapActions(['fetchDashboard', 'fetchTransactions']),
            async loadDashboard() {
                await this.fetchDashboard();
                await this.fetchTransactions({ page: 1, per_page: 10 });
            },
            onTransferSuccess() {
                Swal.fire('Success!', 'Transfer berhasil', 'success');
                this.loadDashboard();
            }
        }
    };
</script>

<style lang="scss" scoped>
    .dashboard-container {
        min-height: calc(100vh - 100px);
    }

    .welcome-card {
        background: gray;
        border-radius: 15px;
        padding: 2rem;
        color: white;
        margin-bottom: 2rem;
        
        h1 {
            margin-bottom: 1rem;
            font-size: 1.5rem;
        }
        
        .balance-card {
            background: rgba(255,255,255,0.2);
            border-radius: 10px;
            padding: 1rem;
            text-align: center;
            
            .balance-label {
                font-size: 0.9rem;
                opacity: 0.9;
            }
            
            .balance-amount {
                font-size: 2.5rem;
                font-weight: bold;
                margin-top: 0.5rem;
            }
        }
    }

    .dashboard-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 1.5rem;
        margin-bottom: 2rem;
    }

    .card {
        background: white;
        border-radius: 10px;
        padding: 1.5rem;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        
        h3 {
            margin-bottom: 1rem;
            color: #333;
            border-bottom: 2px solid #667eea;
            padding-bottom: 0.5rem;
        }
    }

    .full-width {
        grid-column: 1 / -1;
    }

    .statistics {
        .stat-item {
            display: flex;
            justify-content: space-between;
            padding: 0.75rem 0;
            border-bottom: 1px solid #eee;
            
            &:last-child {
                border-bottom: none;
            }
            
            .stat-label {
                color: #666;
            }
            
            .stat-value {
                font-weight: bold;
                color: #333;
            }
            
            .text-success {
                color: #28a745;
            }
            
            .text-danger {
                color: #dc3545;
            }
        }
    }

    @media (max-width: 768px) {
        .dashboard-grid {
            grid-template-columns: 1fr;
        }
    }
</style>