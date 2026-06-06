<template>
    <div class="page">
        <div class="card">
        <h2>Riwayat Transaksi</h2>
        <TransactionList />
        </div>
    </div>
</template>

<script>
    import TransactionList from '@/components/TransactionList.vue'

    export default {
        components: {
            TransactionList
        }
    }
</script>