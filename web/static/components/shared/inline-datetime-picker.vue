<template>
  <div class='inline-datetime-picker'>
    <el-date-picker
     v-on:input="onChange"
     v-model="v"
     :type="type"
     :editable="false"
     :size="size"
     :appendToBody="false"
     :placeholder="placeholder"
     ref="dateTimePicker" />
  </div>
</template>

<script>
  export default {
    props: ['value', 'size', 'placeholder', 'type'],
    data() {
      return {
        v: this.value
      };
    },
    watch: {
      value() {
        this.v = this.value;
      }
    },
    components: {
      'el-date-picker': ElementUi.DatePicker
    },
    methods: {
      onChange(value) {
        this.$emit('change', value);
      }
    },
    mounted() {
      console.log(this);
      this.$refs.dateTimePicker.showPicker();
      this.$refs.dateTimePicker.handleClick = function(item) {
        alert(1, item);
      };
    }
  };
</script>

<style lang="sass">
  .inline-datetime-picker {
    .el-input__icon {
      display: none;
    }

    .el-date-picker {
      display: block !important;
      position: static !important;
      width: 100% !important;
      margin: 0;
      box-shadow: none !important;
    }

    .el-date-editor.el-input {
      width: 100%;
    }

    .el-time-panel {
      min-width: 160px;
    }

    .el-input__inner {
      display: none;
    }

    .el-date-picker__editor-wrap .el-input__inner {
      display: block;
    }

    .el-picker-panel__footer {
      display: none;
    }
  }
</style>
