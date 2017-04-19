<template>
  <div>
    <div v-show="editMode">
      <textarea v-bind:value="value" v-autosize="value" class="inline-textarea"  />
      <button class="btn btn-success" v-on:click="updateValue">Save</button>
      <a @click="cancelEdit">Cancel</a>
    </div>
    <div v-html="compiledMarkdown" v-show="!editMode" @click="editMode=true"></div>
  </div>
</template>

<script>

export default {
  props: ['value'],
  data: function() {
    return {
      editMode: false,
      markdownText: '-empty-' //(new MarkdownIt()).render(this.value)
    };
  },
  computed: {
    compiledMarkdown: function () {
      return this.markdownText || '-empty-';
    }
  },
  methods: {
    updateValue: function(){
      var text = this.$el.querySelector('textarea').value;
      this.$emit('input', text);
      this.markdownText = (new MarkdownIt()).render(text);
      this.editMode=false;
    },
    cancelEdit: function() {
      this.$el.querySelector('textarea').value = this.value;
      this.editMode=false;
    }
  }
};
</script>

<style lang="sass">
  .inline-textarea {
    background-color:transparent;
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
