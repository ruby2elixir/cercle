<template>
  <alert class="tip-notification" :show.sync="show" :placement="placement" :duration.number="2500" :type="type" width="300px" dismissable>
  <span class="icon-ok-circled alert-icon-float-left"></span>
  {{msg}}
  </alert>

  </template>
<script>

  export default {
    data() {
      return {
        show: false,
        msg: '',
        placement: 'top-right',
        type: 'success'
      };
    },
    components: {
      'alert': VueStrap.alert
    },
    mounted() {
      let vm = this;
      vm.$notification.$on('alert', function(options){
        vm.show = true;
        vm.msg = options['msg'];
        if (options['type']) { vm.type = options['type'];  }
        if (options['placement']) {
          vm.placement = options['placement'];
        }
      });
    }
  };
</script>

<style lang="sass">
  .tip-notification { z-index: 9999 !important; }
</style>
