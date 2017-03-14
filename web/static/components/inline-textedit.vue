<template>
  <textarea v-bind:value="value"  v-on:blur="updateValue($event.target.value)" class="inline-textarea"  />
</template>

<script>
export default {
 props: ['value'],
  methods: {
      updateValue: function(value){ this.$emit('input', value)  }
  }
}
</script>

<style lang="sass">
  .inline-textarea {
  border:0px solid grey;
  width:100%;
  height:60px;
  overflow: hidden;
  }
  .inline-textarea:focus {
    outline-width: 0;
    border: 0.01em solid #f7f7f7;
  }
  textarea.inline-textarea{
    resize: none;
  }
</style>
