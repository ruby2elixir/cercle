<template>
  <a href="#" @click="toggleSidebar()" class="btn pull-right" style="margin-top:20px;">
    <i class="fa fa-fw fa-ellipsis-h"></i>
    Show Menu
  </a>
</template>
<script>
  export default {
    data() {
      return {};
    },
    methods: {
      toggleSidebar() {
        let elem = document.querySelector('.control-sidebar-light');
        elem.classList.toggle('open');
      }
    }
  };
  </script>
<style lang="sass">
</style>
