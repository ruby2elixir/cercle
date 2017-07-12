<template>
  <div class="tab-pane active" id="control-sidebar-home-tab" >
    <h3 class="control-sidebar-heading">Recent Activity</h3>
    <ul class="control-sidebar-menu">
      <component v-bind:is="item.event_name" v-for="item in items" :item="item" v-on:clickByEvent="clickByEvent(item)" />
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
import ContactForm from '../contacts/edit.vue';

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
    'contact-form': ContactForm
  },
  methods: {
    clickByEvent(event) {
      if (event.contact_id) {
        this.$glmodal.$emit(
          'open', {
            view: 'contact-form', class: 'contact-modal', data: { 'card_id': event.card_id, 'contact_id': event.contact_id }
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
        this.items = payload.recent;
      });

      this.channel.on('timeline_event:created', payload => {
        this.eventAddOrUpdate(payload);
      });
      this.channel.on('timeline_event:updated', payload => {
        this.eventAddOrUpdate(payload);
      });
      this.channel.on('timeline_event:deleted', payload => {
        let itemIndex = this.$data.items.findIndex(function(item){
          return item.id === parseInt(payload.id);
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
