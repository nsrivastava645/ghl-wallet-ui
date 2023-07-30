<template>
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <div class="container">
            <router-link class="navbar-brand" to="/">Wallet App</router-link>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="navbar-nav mr-auto">
                    <li class="nav-item">
                        <router-link class="nav-link" :to="{ name: 'WalletSetup' }">Wallet Setup</router-link>
                    </li>
                    <li class="nav-item">
                        <router-link class="nav-link" :to="{ name: 'Transactions' }">Transaction List</router-link>
                    </li>
                    <li v-if="hasWalletId" class="nav-item">
                        <router-link @click="logout()" class="nav-link text-danger" :to="{ name: 'WalletSetup' }">
                            Logout
                        </router-link>

                    </li>
                </ul>
            </div>
        </div>
    </nav>
</template>
<script>
export default {
    data() {
        return {
            hasWalletId: false,
        };
    },
    methods: {
        logout() {
            localStorage.removeItem('walletId');
            location.reload();
        }
    },
    mounted() {
        const walletId = localStorage.getItem('walletId');
        if (walletId) {
            this.hasWalletId = true;
        }
    },
}
</script>
  