<template>
  <div class="new-contact" style="padding: 10px;">
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
      <select v-model="column" class="form-control">
        <option v-for="col in columns" :value="col.id">{{ col.name }}</option>
      </select>
    </div>
    <div class="form-group">
      <button class="btn btn-success" v-on:click="saveCard">Save</button>
      <a @click="cancel">Cancel</a>
    </div>
  </div>
</template>

<script>
import vSelect from 'vue-select';
export default {
  props: ['columns'],
  data: function() {
    return {
      name: '',
      email: '',
      phone: '',
      column: ''
    };
  },
  methods: {
    saveCard: function(){
      this.$emit('save-new-contact', this.$data);
    },
    cancel: function() {
      this.$emit('hide-new-contact');
    }
  }
};
</script>
