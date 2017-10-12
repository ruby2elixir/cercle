<template>
  <event :item="item" v-on:clickByEvent="$emit('clickByEvent')">
     <span v-html="content"></span>
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
      let h = ['updated '];
      if (this.item.cardName) {
        h.push(this.item.cardName + ' on ');
      }
      h.push('<a href="' + this.item.boardId + '">'+this.boardName(meta)+'</a>');
      h.push(this.diff());
      return h.join('');
    },
    boardName(boardMeta) {
      let names = [];
      if (boardMeta && boardMeta.boardColumn) {
        names.push(boardMeta.boardColumn.name);
      }
      return names.join(' ');
    },
    mainContact() {
      return this.item.mainContactName;
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
      return this.meta && parseInt(this.meta.boardColumn.id) !== parseInt(this.meta.previous.boardColumn.id);
    },
    content() {
      return this.updatedCardMsg(this.meta);
    }

  }

};
</script>
