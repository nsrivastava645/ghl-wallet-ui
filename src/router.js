import { createRouter, createWebHistory } from 'vue-router';
import WalletSetup from '@/views/WalletSetup.vue';
import TransactionsList from '@/views/TransactionsList.vue';

const routes = [
    { path: '/', component: WalletSetup, name: 'WalletSetup' },
    { path: '/transactions', component: TransactionsList, name: 'Transactions' },
  ];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
