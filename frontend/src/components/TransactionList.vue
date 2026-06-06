<template>
    <div class="transaction-list">
        <div class="filters">
            <div class="filter-group">
                <label>Jenis</label>
                <select v-model="filters.type">
                    <option value="">Semua</option>
                    <option value="credit">Pemasukan</option>
                    <option value="debit">Pengeluaran</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label>Sort By</label>
                <select v-model="filters.sort_by">
                    <option value="created_at">Tanggal</option>
                    <option value="amount">Nominal</option>
                </select>
            </div>
            
            <div class="filter-group">
                <label>Order</label>
                <select v-model="filters.sort_order">
                    <option value="desc">Terbaru/Terbesar</option>
                    <option value="asc">Terlama/Terkecil</option>
                </select>
            </div>
            
            <button @click="applyFilters" class="btn-filter">Filter</button>
            <button @click="resetFilters" class="btn-reset">Reset</button>
        </div>
        
        <div v-if="loading" class="loading">
            <div class="spinner"></div>
        </div>
        
        <div v-else-if="transactions.length > 0" class="table-responsive">
            <table class="transaction-table">
                <thead>
                    <tr>
                        <th>Tanggal</th>
                        <th>Jenis</th>
                        <th>Kategori</th>
                        <th>Nominal</th>
                        <th>Saldo Sebelum</th>
                        <th>Saldo Sesudah</th>
                        <th>Deskripsi</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="transaction in transactions" :key="transaction.id">
                        <td>{{ transaction.date }}</td>
                        <td>
                            <span :class="transaction.type === 'Pemasukan' ? 'text-success' : 'text-danger'">
                                {{ transaction.type }}
                            </span>
                        </td>
                        <td>{{ transaction.category }}</td>
                        <td :class="transaction.type === 'Pemasukan' ? 'text-success' : 'text-danger'">
                            {{ transaction.amount }}
                        </td>
                        <td>{{ transaction.balance_before }}</td>
                        <td>{{ transaction.balance_after }}</td>
                        <td class="description">{{ transaction.description || '-' }}</td>
                    </tr>
                </tbody>
            </table>
        </div>
        
        <div v-else class="empty-state">
            <p>Belum ada transaksi</p>
        </div>
        
        <div v-if="totalPages > 1" class="pagination">
            <button @click="changePage(currentPage - 1)" :disabled="currentPage === 1" class="page-btn">
                Previous
            </button>
            
            <span class="page-info">
                Halaman {{ currentPage }} dari {{ totalPages }}
            </span>
            
            <button @click="changePage(currentPage + 1)" :disabled="currentPage === totalPages" class="page-btn">
                Next
            </button>
        </div>
    </div>
</template>

<script>
    import { mapState, mapActions } from 'vuex';

    export default {
        name: 'TransactionList',
        data() {
            return {
                filters: {
                    type: '',
                    sort_by: 'created_at',
                    sort_order: 'desc'
                },
                loading: false
            };
        },
        computed: {
            ...mapState({
                transactions: state => state.transactions,
                currentPage: state => state.currentPage,
                totalPages: state => state.totalPages
            })
        },
        mounted() {
            this.loadTransactions();
        },
        methods: {
            ...mapActions(['fetchTransactions']),
            async loadTransactions() {

                this.loading = true;

                const params = {};

                if (this.filters.type) {
                    params.type = this.filters.type;
                }

                if (this.filters.sort_by) {
                    params.sort_by = this.filters.sort_by;
                }

                if (this.filters.sort_order) {
                    params.sort_order = this.filters.sort_order;
                }

                await this.fetchTransactions(params);

                this.loading = false;
            },
            async applyFilters() {
                await this.loadTransactions();
            },
            resetFilters() {
                this.filters = {
                    type: '',
                    sort_by: 'created_at',
                    sort_order: 'desc'
                };
                this.loadTransactions();
            },
            async changePage(page) {
                if (page >= 1 && page <= this.totalPages) {
                    await this.fetchTransactions({ ...this.filters, page });
                }
            }
        }
    };
</script>

<style lang="scss" scoped>
    .transaction-list {
        .filters {
            display: flex;
            gap: 1rem;
            margin-bottom: 1.5rem;
            flex-wrap: wrap;
            
            .filter-group {
                flex: 1;
                min-width: 150px;
                
                label {
                    display: block;
                    margin-bottom: 0.25rem;
                    font-size: 0.85rem;
                    color: #666;
                }
                
                select {
                    width: 100%;
                    padding: 0.5rem;
                    border: 1px solid #ddd;
                    border-radius: 5px;
                    background: white;
                }
            }
            
            .btn-filter, .btn-reset {
                padding: 0.5rem 1rem;
                border: none;
                border-radius: 5px;
                cursor: pointer;
                height: fit-content;
                align-self: flex-end;
            }
            
            .btn-filter {
                background: #667eea;
                color: white;
                
                &:hover {
                    background: #5a67d8;
                }
            }
            
            .btn-reset {
                background: #6c757d;
                color: white;
                
                &:hover {
                    background: #5a6268;
                }
            }
        }
        
        .table-responsive {
            overflow-x: auto;
        }
        
        .transaction-table {
            width: 100%;
            border-collapse: collapse;
            
            th, td {
                padding: 1rem;
                text-align: left;
                border-bottom: 1px solid #eee;
            }
            
            th {
                background: #f8f9fa;
                font-weight: 600;
                color: #555;
            }
            
            tr:hover {
                background: #f8f9fa;
            }
            
            .text-success {
                color: #28a745;
                font-weight: 500;
            }
            
            .text-danger {
                color: #dc3545;
                font-weight: 500;
            }
            
            .description {
                max-width: 200px;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
        }
        
        .loading {
            display: flex;
            justify-content: center;
            padding: 2rem;
            
            .spinner {
                width: 40px;
                height: 40px;
                border: 4px solid #f3f3f3;
                border-top: 4px solid #667eea;
                border-radius: 50%;
                animation: spin 1s linear infinite;
            }
        }
        
        .empty-state {
            text-align: center;
            padding: 2rem;
            color: #999;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 1rem;
            margin-top: 1.5rem;
            
            .page-btn {
                padding: 0.5rem 1rem;
                background: #667eea;
                color: white;
                border: none;
                border-radius: 5px;
                cursor: pointer;
                
                &:hover:not(:disabled) {
                    background: #5a67d8;
                }
                
                &:disabled {
                    opacity: 0.5;
                    cursor: not-allowed;
                }
            }
            
            .page-info {
                color: #666;
            }
        }
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    @media (max-width: 768px) {
        .transaction-table {
            font-size: 0.85rem;
            
            th, td {
                padding: 0.5rem;
            }
        }
    }
</style>