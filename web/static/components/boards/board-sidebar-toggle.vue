<template>
  <a @click="toggleSidebar()" class="btn pull-right board-sidebar-toogle open">
    <i class="fa fa-fw fa-ellipsis-h"></i>
    Show Menu
  </a>
</template>
<script>
  export default {
    data() { return { }; },
    methods: {
      toggleSidebar() {
        let menu = document.querySelector('.board-sidebar-toogle');
        menu.classList.toggle('open');
        let elem = document.querySelector('.control-sidebar-light');
        elem.classList.toggle('open');
      }
    }
  };
</script>
<style lang="sass">
  .board-sidebar-toogle {
    margin-top:20px;
    position: absolute;
    right: 0px;
    z-index: 8888;
    display: none;
    &.open {
      display: inline-block;
    }
  }
</style>
