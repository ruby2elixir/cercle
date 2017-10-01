<template>
  <textarea v-bind:value="value"
            v-on:blur="updateValue($event.target.value)"
            class="inline-textarea"
            v-autosize="rawText"
            v-on:keydown.enter="onEnterKey"
            ref="input" rows="1" />
</template>

<script>
export default {
  props: ['value'],
  methods: {
    updateValue: function(value){ this.$emit('input', value);  },
    onEnterKey(event) {
      event.preventDefault();
      this.updateValue(event.target.value);
      this.$refs.input.blur();
    }
  }
};
</script>

<style lang="sass">
  .inline-textarea {
    background-color:transparent;
    border:0px solid grey;
    width:100%;
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
