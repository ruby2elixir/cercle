<template>
  <event :item="item" v-on:clickByEvent="$emit('clickByEvent')">
    about {{item.mainContactName }}
    <template v-if="item.cardName">
      on <a v-on:click.stop="$emit('clickByEvent')">{{item.cardName}}</a>
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
