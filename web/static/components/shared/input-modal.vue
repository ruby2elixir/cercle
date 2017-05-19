<template>
  <span>
    <span v-on:click="showModal">
      {{value || placeholder}}
    </span>

    <div v-show="editMode" class='input-modal'>
      <a class='close' v-on:click='cancel'>X</a>
      <div class="form-group">
        <input type='text' v-model='v' class='form-control' :placeholder='placeholder' />
      </div>
      <div>
        <button class='btn btn-primary btn-block' @click='save'>Save</button>
      </div>
    </div>
  </span>
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
    showModal: function() {
      this.editMode = true;
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
