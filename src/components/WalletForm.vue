<template>
  <div>
    <div v-if="hasWalletId">
      <!-- Wallet details -->
      <div class="container my-5">
        <div class="row justify-content-center">
          <div class="col-md-6">
            <div class="card">
              <div class="card-header">
                <h3 class="mb-0">Wallet Details</h3>
              </div>
              <div class="card-body">
                <p><strong>Name:</strong> {{ walletDetails?.name }}</p>
                <p><strong>Balance:</strong> ₹{{ walletDetails?.balance?.toFixed(4) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Transaction form -->
      <div class="container my-5">
        <div class="row justify-content-center">
          <div class="col-md-6">
            <div class="card">
              <div class="card-header">
                <h3 class="mb-0">Submit Transaction</h3>
              </div>
              <div class="card-body">
                <form @submit.prevent="submitTransaction">
                  <div class="form-group">
                    <label for="transactionType">Transaction Type:</label>
                    <select class="form-control" v-model="transactionType" required>
                      <option value="CREDIT">Credit</option>
                      <option value="DEBIT">Debit</option>
                    </select>
                  </div>
                  <div class="form-group">
                    <label for="amount">Amount:</label>
                    <input type="number" class="form-control" v-model="amount" step="0.0001" required>
                  </div>
                  <div class="form-group">
                    <label for="description">Description:</label>
                    <input type="text" class="form-control" v-model="description" required>
                  </div>
                  <button type="submit" class="btn btn-primary">Submit Transaction</button>
                </form>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create wallet form -->
    <div v-else>
      <div class="container my-5">
        <div class="row justify-content-center">
          <div class="col-md-6">
            <div class="card">
              <div class="card-header">
                <h3 class="mb-0">Create Wallet</h3>
              </div>
              <div class="card-body">
                <form @submit.prevent="submitWallet">
                  <div class="form-group">
                    <label for="name">Name:</label>
                    <input type="text" class="form-control" v-model="name" required>
                  </div>
                  <div class="form-group">
                    <label for="balance">Balance:</label>
                    <input type="number" class="form-control" v-model="balance" required>
                  </div>
                  <button type="submit" class="btn btn-primary">Create Wallet</button>
                </form>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from '@/axios';

export default {
  data() {
    return {
      hasWalletId: false,
      name: '',
      balance: '',
      transactionType: 'credit',
      amount: '',
      description: '',
      walletDetails: {},
    };
  },
  methods: {
    async submitWallet() {
      try {
        const response = await axios.post('wallet/v1/wallet/setup', {
          name: this.name,
          balance: this.balance,
        });
        localStorage.setItem('walletId', response.data.data.wallet._id);
        alert('Wallet created successfully!');
        this.hasWalletId = true;
        this.walletDetails = {
          name: this.name,
          balance: this.balance,
        };
        location.reload();
      } catch (error) {
        console.error('Error:', error.message);
        alert('Error occurred while creating the wallet.');
      }
    },
    async submitTransaction() {
      const walletId = localStorage.getItem('walletId');
      try {
        await axios.post(`/wallet/v1/wallet/transact/${walletId}`, {
          type: this.transactionType,
          amount: this.amount,
          description: this.description,
        });
        alert('Transaction submitted successfully!');
        this.fetchWalletDetails(); // Update wallet details after transaction
        this.resetForm();
      } catch (error) {
        console.error('Error:', error.message);
        alert('Error occurred while submitting the transaction.');
      }
    },
    async fetchWalletDetails() {
      const walletId = localStorage.getItem('walletId');
      try {
        const response = await axios.get(`wallet/v1/wallet/${walletId}`);
        this.hasWalletId = true;
        this.walletDetails = response.data.data.wallet;
      } catch (error) {
        console.error('Error:', error.message);
      }
    },
    resetForm() {
      this.transactionType = '';
      this.amount = '';
      this.description = '';
    }
  },
  mounted() {
    const walletId = localStorage.getItem('walletId');
    if (walletId) {
      this.hasWalletId = true;
      this.fetchWalletDetails();
    }
  },
};
</script>
