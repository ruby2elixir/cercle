<template>
  <div class="tab-pane active" id="control-sidebar-home-tab" >
    <h3 class="control-sidebar-heading">Recent Activity</h3>
    <ul class="control-sidebar-menu">
      <component
        v-bind:is="item.eventName"
        v-for="item in items"
        :item="item"
        v-on:clickByEvent="clickByEvent(item)" />
    </ul>
    <!-- /.control-sidebar-menu -->
  </div>
</template>
<script>
import {Socket, Presence} from 'phoenix';
import moment from 'moment';
import CommentMessage from './events/comment_item.vue';
import CardCreatedMessage from './events/card_created.vue';
import CardUpdatedMessage from './events/card_updated.vue';
import ContactShow from '../contacts/show.vue';

export default {
  props: ['board_id'],
  data() {
    return {
      channel: null,
      items: [ ],
      openEventModal: false,
      selectItemView: null,
      selectItem: {}
    };
  },
  components: {
    'comment': CommentMessage,
    'card.created': CardCreatedMessage,
    'card.updated': CardUpdatedMessage,
    'modal': VueStrap.modal,
    'contact-show': ContactShow
  },
  methods: {
    clickByEvent(event) {
      if (event.cardId) {
        this.$glmodal.$emit(
          'open', {
            view: 'card-show', class: 'card-modal', data: { 'cardId': event.cardId }
          });
      }
    },
    eventAddOrUpdate(event) {
      let itemIndex = this.$data.items.findIndex(function(item){
        return item.id === parseInt(event.id);
      });
      if (itemIndex === -1){
        this.items.unshift(event);
      } else {
        this.$data.items.splice(itemIndex, 1, event);
      }
    },
    initConn() {
      this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
      this.socket.connect();
      this.channel = this.socket.channel('board:' + this.board_id, {});
      this.channel.join()
                .receive('ok', resp => { this.channel.push('get'); })
                .receive('error', resp => { console.log('Unable to join', resp); });

      this.channel.on('activities', payload => {
        var _payload = this.camelCaseKeys(payload);
        this.items = _payload.recent;
      });

      this.channel.on('timeline_event:created', payload => {
        var _payload = this.camelCaseKeys(payload);
        this.eventAddOrUpdate(_payload);
      });
      this.channel.on('timeline_event:updated', payload => {
        var _payload = this.camelCaseKeys(payload);
        this.eventAddOrUpdate(_payload);
      });
      this.channel.on('timeline_event:deleted', payload => {
        var _payload = this.camelCaseKeys(payload);
        let itemIndex = this.$data.items.findIndex(function(item){
          return item.id === parseInt(_payload.id);
        });
        this.$data.items.splice(itemIndex, 1);
      });

    },
    changeContactDisplay(contactId) {
      this.$set(this.selectItem, 'contact_id', contactId);
    }

  },
  mounted() {
    this.initConn();
  }
};
  </script>
<style lang="sass">

</style>
