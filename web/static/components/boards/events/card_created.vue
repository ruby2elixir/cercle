<template>
  <event :item="item" v-on:clickByEvent="$emit('clickByEvent')">
    added <a :href="'/contact/' + contact.id" v-for="contact in meta.contacts">{{contact.first_name}} {{contact.last_name}}</a>
    to <a :href="'/board/' + item.board_id">{{toName}}</a>
    <br />
  </event>

</template>
<script>
import moment from 'moment';
import EventTemplate from './base_template.vue';

export default {
  props: ['item'],
  components: { 'event': EventTemplate },
  methods: { },
  computed: {
    meta() {
      return this.item.metadata;
    },
    toName() {
      let bName = [];
      if (this.meta && this.meta.board_column) {
        bName.push(this.meta.board_column.name);
      }
      return bName.join(' ');
    }

  }
};
</script>
