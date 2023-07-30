<template>
  <div class="container my-5">
    <div class="row">
      <div class="col-md-12">
        <h3 class="mb-3">Transactions</h3>
        <button @click="downloadTransactions('xlsx')" class="btn btn-success m-2">Download (XLSX)</button>
        <button @click="downloadTransactions('csv')" class="btn btn-success m-2">Download (CSV)</button>
        <button @click="downloadTransactions('xlsx', true)" class="btn btn-success m-2">Download All (XLSX)</button>
        <button @click="downloadTransactions('csv', true)" class="btn btn-success m-2">Download ALL(CSV)</button>
        <table class="table table-striped">
          <thead>
            <tr>
              <th @click="sortTransactions('id')">ID<span :class="getSortClass('_id')"></span></th>
              <th @click="sortTransactions('type')"><span :class="getSortClass('type')"></span>Type</th>
              <th @click="sortTransactions('amount')"><span :class="getSortClass('amount')"></span>Amount</th>
              <th @click="sortTransactions('balance')"><span :class="getSortClass('balance')"></span>Updated Balance</th>
              <th @click="sortTransactions('description')">De<span :class="getSortClass('description')"></span>scription</th>
              <th @click="sortTransactions('date')"><span :class="getSortClass('date')"></span>Transaction Time</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="transaction in sortedTransactions" :key="transaction._id">
              <td>{{ transaction._id }}</td>
              <td>{{ transaction.type }}</td>
              <td>₹{{ transaction.amount }}</td>
              <td>₹{{ transaction.balance }}</td>
              <td>{{ transaction.description }}</td>
              <td>{{ formatDate(transaction.date) }}</td>
            </tr>
          </tbody>
        </table>
        <div class="form-inline mb-3">
          <label for="recordsPerPage">Records Per Page:</label>
          <select class="form-control ml-2" v-model="transactionsPerPage" @change="resetPage">
            <option v-for="option in pageOptions" :key="option" :value="option">{{ option }}</option>
          </select>
        </div>
      </div>
    </div>
    <div class="row mt-3 justify-content-center">
      <div class="col-md-6">
        <div class="text-center">
          <button @click="prevPage" :disabled="currentPage === 1" class="btn btn-secondary">Prev</button>
          <span class="mx-3">Page {{ currentPage }} of {{ totalPages }}</span>
          <button @click="nextPage" :disabled="currentPage === totalPages" class="btn btn-secondary">Next</button>
          <span class="mx-3"> Total Records: {{ totalRecords }}</span>
        </div>
      </div>
    </div>

  </div>
</template>

<style>
.sort-caret {
  display: inline-block;
  width: 0;
  height: 0;
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  vertical-align: middle;
}

/* Style for caret indicator pointing up */
.sort-caret.asc {
  border-bottom: 4px solid #000;
  /* Change color or use an icon for the caret */
}

/* Style for caret indicator pointing down */
.sort-caret.desc {
  border-top: 4px solid #000;
  /* Change color or use an icon for the caret */
}
</style>
<script>
import axios from '@/axios';
import * as XLSX from 'xlsx/xlsx.mjs';

export default {
  data() {
    return {
      transactions: [],
      currentPage: 1,
      transactionsPerPage: 10,
      sortBy: 'date',
      orderBy: -1,
      totalRecords: 0,
    };
  },
  computed: {
    totalPages() {
      return Math.ceil(this.totalRecords / this.transactionsPerPage); // Use totalRecords for pagination
    },
    sortedTransactions() {
      return this.transactions.slice().sort((a, b) => {
        if (this.sortBy) {
          // Numerical comparison
          if (typeof a[this.sortBy] === 'number') {
            return this.orderBy === 1 ? a[this.sortBy] - b[this.sortBy] : b[this.sortBy] - a[this.sortBy];
          }

          // For other fields, use string comparison
          const comparison = a[this.sortBy].localeCompare(b[this.sortBy]);
          return this.orderBy === 1 ? comparison : -comparison;
        }
        return 0;
      });
    },
    pageOptions() {
      // Available options for records per page
      return [5, 10, 20, 50];
    },
  },
  methods: {
    updateUrlParams() {
      const newUrl = `?page=${this.currentPage}&limit=${this.transactionsPerPage}&sortBy=${this.sortBy}&orderBy=${this.orderBy}`;
      window.history.pushState({ path: newUrl }, '', newUrl);
    },
    async fetchTransactions() {
      try {
        const walletId = localStorage.getItem('walletId');
        const response = await axios.get(`wallet/v1/wallet/transactions?walletId=${walletId}&limit=${this.transactionsPerPage}&offset=${this.currentPage}&sortBy=${this.sortBy}&orderBy=${this.orderBy}`);

        this.transactions = response?.data?.data?.transactions;
        this.totalRecords = response?.data?.data?.totalRecords; // Set totalRecords from the response
        this.updateUrlParams();
      } catch (error) {
        console.error('Error:', error.message);
      }
    },
    async downloadTransactions(type, downloadAll) {
      try {
        const walletId = localStorage.getItem('walletId');
        let response;
        if (downloadAll) {
          response = await axios.get(`wallet/v1/wallet/transactions/all/${walletId}`, {
            responseType: 'json', // Set responseType to 'json' to get JSON data from the response
          });
        } else {
          response = await axios.get(`wallet/v1/wallet/transactions?walletId=${walletId}&limit=${this.transactionsPerPage}&offset=${this.currentPage}&sortBy=${this.sortBy}&orderBy=${this.orderBy}`, {
            responseType: 'json', // Set responseType to 'json' to get JSON data from the response
          });
        }

        const transactions = response?.data?.data?.transactions;
        switch (type) {
          case 'xlsx': {
            // Prepare the Excel data
            const worksheet = XLSX.utils.json_to_sheet(transactions);
            const workbook = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(workbook, worksheet, 'Transactions');

            // Generate the file and create a Blob
            const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
            const blob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });

            // Create a temporary URL for the Blob
            const url = window.URL.createObjectURL(blob);

            // Create a temporary link to download the file
            const link = document.createElement('a');
            link.href = url;
            link.download = 'transactions.xlsx';
            link.click();

            // Clean up the temporary URL
            window.URL.revokeObjectURL(url);
            break;
          }
          case 'csv': {
            const csvData = this.convertToCSV(transactions);
            // Create a Blob from the CSV data
            const blob = new Blob([csvData], { type: 'text/csv' });

            // Create a temporary URL for the Blob
            const url = window.URL.createObjectURL(blob);

            // Create a temporary link to download the file
            const link = document.createElement('a');
            link.href = url;
            link.download = 'transactions.csv';
            link.click();

            // Clean up the temporary URL
            window.URL.revokeObjectURL(url);
            break;
          }
        }
      } catch (error) {
        console.error('Error:', error.message);
        alert('Error occurred while downloading transactions.');
      }
    },
    convertToCSV(data) {
      const headers = Object.keys(data[0]).join(',');
      const rows = data.map(row => Object.values(row).join(','));
      return `${headers}\n${rows.join('\n')}`;
    },
    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++;
        this.fetchTransactions();
        this.updateUrlParams();
      }
    },
    prevPage() {
      if (this.currentPage > 1) {
        this.currentPage--;
        this.fetchTransactions();
        this.updateUrlParams();
      }
    },
    sortTransactions(key) {
      // Toggle sorting direction if the same key is clicked again
      if (this.sortBy === key) {
        this.orderBy = this.orderBy === 1 ? -1 : 1;
      } else {
        this.sortBy = key;
        this.orderBy = -1;
      }
      this.fetchTransactions();
      this.updateUrlParams();
    },
    resetPage() {
      this.currentPage = 1;
      this.fetchTransactions();
    },
    formatDate(dateString) {
      const date = new Date(dateString);
      const options = {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      };
      return date.toLocaleDateString('en-IN', options);
    },
    getSortClass(key) {
      // Return the appropriate CSS class based on the current sortBy and orderBy
      return {
        'sort-caret': this.sortBy === key,
        'asc': this.sortBy === key && this.orderBy === 1,
        'desc': this.sortBy === key && this.orderBy === -1,
      };
    },

  },
  mounted() {
    this.fetchTransactions();
  },
};
</script>

