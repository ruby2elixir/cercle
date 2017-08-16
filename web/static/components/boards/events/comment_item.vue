<template>
  <event :item="item" v-on:clickByEvent="$emit('clickByEvent')">
    about {{item.mainContactName }}
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
