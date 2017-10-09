e<template>
  <input type="text" v-bind:value="value"  v-on:blur="updateValue($event.target.value)" class="inline-input" ref="input"  />
</template>

<script>
export default {
  props: ['value'],
  methods: {
    updateValue: function(value){ this.$emit('input', value);  }
  }
};
</script>

<style lang="sass">
  .inline-input {
  background-color:transparent;
  border:0px solid grey;
  display:inline !important;
  }
  input.inline-input:focus {
    outline-width: 0;
    border: 0.01em solid #f7f7f7;
  }
  textarea.inline-input{
    resize: none;
  }
</style>
