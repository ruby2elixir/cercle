<template>
  <span v-on-click-outside='cancel'>
    <span v-on:click="showModal" class="full-name">
      {{firstName}} {{lastName}}
    </span>

    <div v-show="editMode" class='input-modal'>
      <div class='modal-header clearfix'>
        Change Name
        <a class='close pull-right' v-on:click='cancel'>×</a>
      </div>

      <div class='modal-body name-edit-modal'>
        <div class="form-group">
          <label>First name</label>
          <input type='text' v-model='fname'
                 class='form-control fname'
                 placeholder='First name'
                 v-on:keyup.enter="save"
                 v-on:keyup.esc.stop="cancel" ref='fname' />
        </div>
        <div class="form-group">
          <label>Last name</label>
          <input type='text' v-model='lname'
                 class='form-control lname'
                 placeholder='Last name'
                 v-on:keyup.enter="save"
                 v-on:keyup.esc.stop="cancel" />
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
  props: ['firstName', 'lastName'],
  data() {
    return {
      editMode: false,
      fname: this.firstName,
      lname: this.lastName
    };
  },
  watch: {
    'firstName': function() {
      this.fname = this.firstName;
    },
    'lastName': function() {
      this.lname = this.lastName;
    }
  },
  methods: {
    showModal: function() {
      this.editMode = true;
      var vue = this;
      Vue.nextTick(function () {
        vue.$refs.fname.focus();
      });
    },
    save: function() {
      this.$emit('input', {firstName: this.fname, lastName: this.lname});
      this.editMode = false;
    },
    cancel: function() {
      this.fname = this.firstName;
      this.lname = this.lastName;
      this.editMode = false;
    }
  }
};
</script>
