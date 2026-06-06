<template>
    <div class="dashboard">
        <section class="wallet-card">
            <div class="wallet-header">
                <div>
                    <p class="welcome">
                        Halo, {{ userName }}
                    </p>
                    <h2>Saldo Saat Ini</h2>
                </div>
            </div>

            <div class="balance">
                {{ formattedBalance }}
            </div>
        </section>

        <section class="stats-grid" v-if="statistics">
            <div class="stat-card">
                <p>Total Transaksi</p>
                <h3>
                    {{ statistics.total_transactions }}
                </h3>
            </div>

            <div class="stat-card">
                <p>Total Terkirim</p>
                <h3>
                    {{ statistics.total_sent }}
                </h3>
            </div>

            <div class="stat-card">
                <p>Total Diterima</p>
                <h3>
                    {{ statistics.total_received }}
                </h3>
            </div>

        </section>

    </div>
</template>

<script>
    import { mapGetters } from 'vuex'

    export default {
        computed: {
            ...mapGetters([
                'userName',
                'formattedBalance'
            ]),

            statistics() {
                return this.$store.state.statistics
            }
        },

        mounted() {
            this.$store.dispatch('fetchDashboard')
        }
    }
</script>

<style>
    .dashboard {
        display: flex;
        flex-direction: column;
        gap: 24px;
    }

    .wallet-card {
        background: #2563eb;
        color: white;
        border-radius: 20px;
        padding: 32px;
        box-shadow: 0 15px 30px rgba(37,99,235,.15);
    }

    .welcome {
        opacity: .9;
        margin-bottom: 6px;
    }

    .balance {
        margin-top: 20px;
        font-size: 42px;
        font-weight: 700;
    }

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit,minmax(220px,1fr));
        gap: 20px;
    }

    .stat-card {
        background: white;
        border-radius: 16px;
        padding: 24px;
        border: 1px solid #e5e7eb;
        transition: .2s;
    }

    .stat-card:hover {
        transform: translateY(-4px);
    }

    .stat-card p {
        color: #6b7280;
        margin-bottom: 10px;
    }

    .stat-card h3 {
        color: #111827;
        font-size: 24px;
    }
</style>