<template>
  <span>
    <span v-on:click="showModal">
      {{firstName}} {{lastName}}
    </span>

    <div v-show="editMode" class='input-modal'>
      <a class='close' v-on:click='cancel'>X</a>
      <div class="form-group">
        <div class="row">
          <div class='col-sm-6'>
            <input type='text' v-model='fname' class='form-control' placeholder='First name' />
          </div>
          <div class='col-sm-6'>
            <input type='text' v-model='lname' class='form-control' placeholder='Last name' />
          </div>
        </div>
      </div>
      <div>
        <button class='btn btn-primary btn-block' @click='save'>Save</button>
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
