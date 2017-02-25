<template>
  <input type="text" v-bind:value="value"  v-on:blur="updateValue($event.target.value)" class="inline-input" style="border:0px solid grey;width:100%;line-height:30px;height:30px;" />
</template>

<script>
export default {
  methods: {
      updateValue: function(value){ this.$emit('input', value)  }
  }
}
</script>

<style lang="sass">
  .inline-input {
  border:0px solid grey;
  width:100%;
  line-height:30px;
  height:30px;
  }
  input:focus {
    outline-width: 0;
  }
  textarea{
    resize: none;
  }
</style>
