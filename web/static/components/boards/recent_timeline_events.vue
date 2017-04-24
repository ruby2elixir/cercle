<template>
  <div class="tab-pane active" id="control-sidebar-home-tab" >
    <h3 class="control-sidebar-heading">Recent Activity</h3>
    <ul class="control-sidebar-menu">
      <component v-bind:is="item.event_name" v-for="item in items" :item="item" />
    </ul>
    <!-- /.control-sidebar-menu -->
  </div>
</template>
<script>
import {Socket, Presence} from 'phoenix';
import moment from 'moment';
import CommentMessage from './events/comment_item.vue';

export default {
  props: ['board_id'],
  data() {
    return {
      channel: null,
      items: [ ]
    };
  },
  components: {
    'comment': CommentMessage
  },
  methods: {
    initConn() {
      this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
      this.socket.connect();
      this.channel = this.socket.channel('board:' + this.board_id, {});
      this.channel.join()
                .receive('ok', resp => { this.channel.push('get'); })
                .receive('error', resp => { console.log('Unable to join', resp); });

      this.channel.on('activities', payload => {
        this.items = payload.recent;
      });

      this.channel.on('timeline_event:created', payload => {
        this.items.unshift(payload);
      });

    }

  },
  mounted() {
    this.initConn();
  }
};
  </script>
<style lang="sass">

</style>
