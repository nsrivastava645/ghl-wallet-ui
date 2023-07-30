<template>
    <div>
        <navigation-bar></navigation-bar>
        <wallet-form></wallet-form>
    </div>
</template>
  
<script>
import WalletForm from '@/components/WalletForm.vue';
import NavigationBar from '@/components/NavigationBar.vue';
export default {
    components: {
    WalletForm,
    NavigationBar
},
};
</script>
  