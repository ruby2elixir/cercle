<template>
  <div class="box-tools pull-right dropdown " :class="{ open: isActive }">
    <button type="button" class="btn btn-box-tool"  v-on:click="isActive = !isActive"><i class="fa fa-fw fa-angle-down"></i></button>
    <ul class="dropdown-menu" v-on:click="closeList($event)">
      <slot></slot>
    </ul>
  </div>
</template>
<script>
export default {
  data() { 
    return {  isActive: false };
  },
  methods: {
    closeList(event) {
      event.preventDefault();
      this.isActive = false;
    }
  }
};
</script>
<style lang="sass">
</style>

