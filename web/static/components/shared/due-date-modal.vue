<template>
  <span>
    <span v-on:click="showModal" class="date-display">
      <slot>
        <span v-if="v">{{v|formatDateTime}}</span>
        <span v-else>Add due date</span>
      </slot>
    </span>

    <div v-show="editMode" class='input-modal due-date-modal'>
      <div class='modal-header clearfix'>
        <span>Add due date</span>
        <a class='close pull-right' v-on:click='cancel' v-if="!inline">×</a>
      </div>

      <div class='modal-body'>
        <inline-datetime-picker
         v-model="v"
         type="datetime"
         :editable="false"
         :min_date="new Date()"
         size="mini"
         format="yyyy-MM-dd HH:mm"
         :clearable="true" />
      </div>

      <div class="row input-modal-footer">
        <div class="col-md-3">
          <button class="btn btn-default btn-block" @click="remove"><span class="text-danger">Remove</span></button>
        </div>
        <div class="col-md-3 col-md-offset-6 text-right">
          <button class="btn btn-primary btn-block" @click="save">Save</button>
        </div>
      </div>
    </div>
  </span>
</template>

<script>
  import SelectMember from './select-member.vue';
  import InlineDatetimePicker from './inline-datetime-picker.vue';
  export default {
    props: ['value'],
    data() {
      return {
        editMode: false,
        v: this.value
      };
    },
    watch: {
      value() {
        this.v = this.value;
      }
    },
    components: {
      'inline-datetime-picker': InlineDatetimePicker
    },
    methods: {
      showModal: function() {
        this.editMode = true;
      },
      closeModal() {
        this.editMode = false;
        if(this.handleClose) {
          this.handleClose();
        }
      },
      cancel: function() {
        this.closeModal();
      },
      save() {
        // Following hack is required because, inline datetime picker doesnt emit instantly when date is picked
        let datetimeInputs = $('.el-picker-panel__body input', this.$el);
        let datetime = datetimeInputs[0].value + ' ' + datetimeInputs[1].value;

        this.$emit('input', datetime);
        this.$emit('change');
        this.closeModal();
      },
      remove() {
        this.v = '';
        this.$emit('input', null);
        this.$emit('change');
        this.closeModal();
      }
    }
  };
</script>

<style lang="sass" scoped>
  .due-date-modal {
    width: 400px;
    padding: 10px;
    z-index: 10;

    .input-modal-footer {
      margin-top: 10px;
    }
  }
</style>
