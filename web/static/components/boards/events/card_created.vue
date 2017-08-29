<template>
  <event :item="item" v-on:clickByEvent="$emit('clickByEvent')">

    added {{item.cardName}} (<a :href="'/contact/' + contact.id" v-for="contact in meta.contacts">{{contact.firstName}} {{contact.lastName}}</a>)

    to <a :href="'/board/' + item.boardId">{{toName}}</a>
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
      if (this.meta && this.meta.boardColumn) {
        bName.push(this.meta.boardColumn.name);
      }
      return bName.join(' ');
    }

  }
};
</script>
