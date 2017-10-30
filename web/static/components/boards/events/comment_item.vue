<template>
  <event :item="item" v-on:clickByEvent="$emit('clickByEvent')">
    about {{item.mainContactName }}
    <template v-if="item.cardName">
      on <u>{{item.cardName}}</u>
    </template>
    <br />
    <div class="comment-message" >
     {{ item.content }}
    </div>
  </event>
</template>
<script>
import moment from 'moment';
import EventTemplate from './base_template.vue';
export default {
  props: ['item'],
  components: { 'event': EventTemplate }
};
</script>
