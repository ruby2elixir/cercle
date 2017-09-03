<template>
  <span v-on-click-outside='cancel'>
    <span v-on:click="showModal" :class="buttonClass">
      <slot>Add due date</slot>
    </span>

    <div v-show="editMode" class='input-modal assignment-modal'>
      <div class='modal-header clearfix'>
        <span>Add due date</span>
        <a class='close pull-right' v-on:click='cancel' v-if="!inline">×</a>
      </div>

      <div class='modal-body'>
        <div class="row">
          <div class="col-md-5">
            <select-member class="inline-mode" v-model="uid" @change="userChanged" :users="users" :inline="true" :disableUnselect="true" />
          </div>

          <div class="col-md-7">
            <inline-datetime-picker
             v-on:change="dateChanged"
             v-model="dt"
             type="datetime"
             :editable="false"
             size="mini"
             placeholder="Select date and time" />
          </div>
        </div>
      </div>

      <div class="row input-modal-footer">
        <div class="col-md-3">
          <button class="btn btn-primary btn-block" @click="save">Save</button>
        </div>
        <div class="col-md-3 col-md-offset-6 text-right">
          <button class="btn btn-default btn-block" @click="remove"><span class="text-danger">Remove</span></button>
        </div>
      </div>
    </div>
  </span>
</template>

<script>
  import SelectMember from './select-member.vue';
  import InlineDatetimePicker from './inline-datetime-picker.vue';
  export default {
    props: ['users', 'userId', 'date'],
    data() {
      return {
        editMode: false,
        uid: this.userId || parseInt(Vue.currentUser.userId),
        dt: this.date
      };
    },
    watch: {
      userId() {
        this.uid = this.userId;
      },
      date() {
        this.dt = this.date;
      }
    },
    components: {
      'el-date-picker': ElementUi.DatePicker,
      'inline-datetime-picker': InlineDatetimePicker,
      'select-member': SelectMember
    },
    methods: {
      showModal: function() {
        this.editMode = true;
      },
      cancel: function() {
        this.editMode = false;
      },
      userChanged(value) {
        this.uid = value;
      },
      dateChanged(value) {
      },
      save() {
        // Following hack is required because, inline datetime picker doesnt emit instantly when date is picked
        let datetimeInputs = $('.el-picker-panel__body input', this.$el);
        let datetime = datetimeInputs[0].value + ' ' + datetimeInputs[1].value;

        this.$emit('change', {userId: this.uid, dueDate: datetime});
        this.editMode = false;
      },
      remove() {
        this.uid = '';
        this.dt = '';
        this.$emit('change', {userId: this.uid, dueDate: this.dt});
        this.editMode = false;
      }
    }
  };
</script>

<style lang="sass" scoped>
  .assignment-modal {
    min-width: 750px;
    margin-left: -50%;
    padding: 10px;

    .input-modal-footer {
      margin-top: 10px;
    }
  }
</style>
