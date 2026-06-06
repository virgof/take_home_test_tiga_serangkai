<template>
    <div class="page">
        <div class="card">
            <h2>Transfer Dana</h2>
            <TransferForm @transfer-success="onTransferSuccess" />
        </div>
    </div>
</template>

<script>
    import TransferForm from '@/components/TransferForm.vue'
    import Swal from 'sweetalert2'

    export default {
        components: {
            TransferForm
        },

        methods: {
            onTransferSuccess(data) {
                Swal.fire({
                    icon: 'success',
                    title: 'Transfer Berhasil',
                    text: `Ref : ${data.reference_id}`
                })
                this.$store.dispatch('fetchDashboard')
                this.$store.dispatch(
                    'fetchTransactions'
                )
            }
        }
    }
</script>