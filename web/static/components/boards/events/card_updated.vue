<template>
  <event :item="item" v-on:clickByEvent="$emit('clickByEvent')">
     <span v-if="isMovedCard">
         moved <a :href="'/contact/' + contact.id" v-for="contact in meta.contacts">{{contact.first_name}} {{contact.last_name}}</a>
         from {{boardName(meta.previous) }} to {{boardName(meta)}}
         </span>
         <span v-else>{{content}}</span>

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
      return 'updated ' + this.boardName(meta);
    },
    boardName(boardMeta) {
      let names = [];
      if (boardMeta && boardMeta.board) {
        names.push(boardMeta.board.name);
      }
      if (boardMeta && boardMeta.board_column) {
        names.push(boardMeta.board_column.name);
      }
      return names.join(' - ');
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
