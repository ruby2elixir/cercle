<template>
  <event :item="item" v-on:clickByEvent="$emit('clickByEvent')">
     <span v-if="isMovedCard">
         moved <a :href="'/contact/' + contact.id" v-for="contact in meta.contacts">{{contact.first_name}} {{contact.last_name}}</a>
         from {{boardName(meta.previous) }} to {{boardName(meta)}}
         </span>
     <span v-else v-html="content">
     </span>
  </event>
</template>
<script>
import moment from 'moment';
import EventTemplate from './base_template.vue';
export default {
  props: ['item'],
  components: { 'event': EventTemplate },
  methods: {
    updatedCardMsg(meta) {
      return 'updated ' + this.boardName(meta) +
            '<br/><i><small>Main contact: ' + this.mainContact() + '</small></i>' +
            this.diff();
    },
    boardName(boardMeta) {
      let names = [];
      if (boardMeta && boardMeta.board_column) {
        names.push(boardMeta.board_column.name);
      }
      return names.join(' ');
    },
    mainContact() {
      return this.item.main_contact_name;
    },
    diff() {
      let changes = [];
      let meta = this.item.metadata;
      if (meta.previous.status !== meta.status) {
        let status = { 0: 'OPEN', 1: 'CLOSED' };
        changes.push('Change status from ' +
                     status[meta.previous.status] + ' to '
                     + status[meta.status]);
      }
      if (changes.length > 0) {
        return '<br /><i><small>' + changes.join(', ') + '</small></i>';
      } else { return ''; }
    }
  },
  computed: {
    meta() {
      return this.item.metadata;
    },
    isMovedCard() {
      return this.meta && parseInt(this.meta.board_column.id) !== parseInt(this.meta.previous.board_column.id);
    },
    content() {
      return this.updatedCardMsg(this.meta);

    }

  }

};
</script>
