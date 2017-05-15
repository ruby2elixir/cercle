<template>
  <div>
    <div v-show="editMode">
      <textarea v-model="rawText" v-autosize="rawText" class="opportunity-textarea"  />
      <button class="btn btn-success" v-on:click="updateValue">Save</button>
      <a @click="cancelEdit">Cancel</a>
    </div>
    <div v-html="compiledMarkdown" v-show="!editMode" @click="editMode=true" class="opportunity-description-rendering"></div>
  </div>
</template>

<script>

export default {
  props: ['value', 'placeholder'],
  data: function() {
    return {
      editMode: false,
      rawText: this.value
    };
  },
  computed: {
    compiledMarkdown: function () {
      return this.rawText ? (new MarkdownIt({breaks:true})).render(this.rawText) : this.placeholder;
    }
  },
  methods: {
    updateValue: function(){
      this.$emit('input', this.rawText);
      this.editMode=false;
    },
    cancelEdit: function() {
      this.rawText = this.value;
      this.editMode=false;
    }
  },
  watch: {
    value: function(val) {
      this.rawText = val;
    }
  }
};
</script>

<style lang="sass">
.opportunity-description-rendering{
  color:rgb(51, 51, 51);
  word-wrap: break-word;
  }
  .opportunity-textarea {
    background-color:white;
    border:1px solid #eeeeee;
    width:100%;
    min-height:100px;
    overflow: hidden;
    margin-bottom:10px;
    border-radius:3px;
    resize: none;

  }
  .inline-textarea:focus {
    outline-width: 0;
    border: 0.01em solid #f7f7f7;
  }
  textarea.inline-textarea{
    resize: none;
  }
</style>
