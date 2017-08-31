<template>
  <div v-on-click-outside='cancel'>
    <span v-on:click="setEditMode" v-show="!editMode">
      {{value || placeholder}}
    </span>

    <div v-show="editMode">
      <div class="form-group">
        <textarea type='text' v-model='v' class='form-control' :placeholder='placeholder' v-on:keydown.enter.stop="save" v-on:keyup.esc.stop="cancel" ref='input' v-autosize="rawText" rows="1" />
      </div>
      <div>
        <button class='btn btn-success' @click='save'>Save</button>
        <a href="#" @click.stop="cancel">Cancel</a>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: ['value', 'placeholder'],
  data() {
    return {
      editMode: false,
      v: this.value
    };
  },
  watch: {
    'value': function() {
      this.v = this.value;
    }
  },
  methods: {
    setEditMode: function() {
      this.editMode = true;
      var vue = this;
      Vue.nextTick(function () {
        vue.$refs.input.focus();
      });
    },
    save: function() {
      this.$emit('input', this.v);
      this.editMode = false;
    },
    cancel: function() {
      this.v = this.value;
      this.editMode = false;
    }
  }
};
</script>
