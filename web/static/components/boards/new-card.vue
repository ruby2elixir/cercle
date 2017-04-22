<template>
  <div class="portlet ui-widget ui-widget-content ui-helper-clearfix ui-corner-all new-card">
    <h5>New card</h5>
      <div class="form-group">
        <input type="text" v-model="name" placeholder="Name" class="form-control" />
      </div>
      <div class="form-group">
        <input type="email" v-model="email" placeholder="Email" class="form-control" />
      </div>
      <div class="form-group">
        <input type="phone" v-model="phone" placeholder="phone" class="form-control" />
      </div>
      <div class="form-group">
        <button class="btn btn-success" v-on:click="saveCard">Save</button>
        <a @click="cancel">Cancel</a>
      </div>
  </div>
</template>

<script>

export default {
  props: [],
  data: function() {
    return {
      name: '',
      email: '',
      phone: ''
    };
  },
  methods: {
    saveCard: function(){
      this.$emit('save-new-card', this.$data);
    },
    cancel: function() {
      this.$emit('hide-new-card');
    }
  }
};
</script>
