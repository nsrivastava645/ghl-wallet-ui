<template>
  <div>
    <navigation-bar></navigation-bar>
    <transaction-list></transaction-list>
  </div>
</template>
  
<script>
import TransactionList from '@/components/TransactionList.vue';
import NavigationBar from '@/components/NavigationBar.vue';
export default {
  components: {
    TransactionList,
    NavigationBar
  },
};
</script>
  