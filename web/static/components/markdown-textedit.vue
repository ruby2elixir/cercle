<template>
  <div>
    <div v-show="editMode">
      <textarea v-model="rawText" v-autosize="rawText" class="inline-textarea"  />
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
      rawText: this.value,
      markdownText: ''
    };
  },
  computed: {
    compiledMarkdown: function () {
      return this.markdownText || this.rawText;
    }
  },
  methods: {
    updateValue: function(){
      this.$emit('input', this.rawText);
      this.markdownText = (new MarkdownIt()).render(this.rawText);
      this.editMode=false;
    },
    cancelEdit: function() {
      this.rawText = this.value;
      this.editMode=false;
    }
  },
  mounted: function(){
    var _v = this;
    window.setTimeout(function(){
      _v.rawText = _v.value;
      _v.markdownText = (new MarkdownIt()).render(_v.rawText);
    }, 1000);
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
