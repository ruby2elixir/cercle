<template>
  <span>
    <span v-on:click="showModal">
      {{value || placeholder}}
    </span>

    <div v-show="editMode" class='input-modal'>
      <div class='modal-header clearfix'>
        <span v-if="label">Change {{label}}</span>
        <a class='close pull-right' v-on:click='cancel'>×</a>
      </div>

      <div class='modal-body'>
        <div class="form-group">
          <label v-if="label">{{label}}</label>
          <input type='text' v-model='v' class='form-control' :placeholder='placeholder' v-on:keyup.enter="save" v-on:keyup.esc.stop="cancel" />
        </div>
        <div>
          <button class='btn btn-primary btn-block' @click='save'>Save</button>
        </div>
      </div>
    </div>
  </span>
</template>

<script>
export default {
  props: ['value', 'placeholder', 'label'],
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
