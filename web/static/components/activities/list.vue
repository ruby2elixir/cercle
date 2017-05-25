<script>
  import {Socket, Presence} from 'phoenix';
  import InlineEdit from '../inline-common-edit.vue';
  import ContactForm from '../contacts/edit.vue';
  import ActivityItem from './item.vue';

  export default {
    data() {
      return {
        timeZone: null,
        showContact: false,
        contact: {},
        card: {},
        contactView: null,
        activities: [],
        activitiesOverdue: [],
        activitiesLater: [],
        activitiesToday: [],
        socket: null,
        channel: null,
        userId: null
      };
    },
    components: {
      'inline-edit': InlineEdit,
      'modal': VueStrap.modal,
      'contact-form': ContactForm,
      'activity-item': ActivityItem
    },
    methods: {
      doneTask(task) {
        this.deleteItem(this.activities, task.id);
      },
      itemClass(item) {
        if (Moment(item.due_date).isSame(new Date(), 'day')) {
          return 'today';
        } else {
          return 'other';
        }
      },
      contactShow(contactId, cardId) {
        this.showContact = null;
        this.contact = {id: contactId};
        this.card = { id: cardId };
        this.contactView = 'contact-form';
        this.showContact = true;
      },
        initConn() {
          let url = '/api/v2/activity'
          this.$http.get(url, { params: { user_id: Vue.currentUser.userId }}).then(resp => {
          this.activities = resp.data.activities;
        });

        this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
        this.socket.connect();
        this.channel = this.socket.channel('users:' + this.userId, {});

        this.channel.join()
              .receive('ok', resp => {  })
              .receive('error', resp => { console.log('Unable to join', resp); });

        this.channel.on('activity:deleted', payload => {
          this.deleteItem(this.activities, payload.activity_id);
        });

        this.channel.on('activity:created', payload => {
          this.$data.activities.push(payload.activity);
        });

        this.channel.on('activity:updated', payload => {
          this.updateItem(this.activities, payload.activity);
        });
      },
      updateItem(collection, data) {
        let itemIndex = collection.findIndex(function(item){
          return item.id === parseInt(data.id);
        });
        if (itemIndex >= 0) { collection.splice(itemIndex, 1, data); }
      },
      deleteItem(collection, id) {
        let itemIndex = collection.findIndex(function(item){
          return item.id === parseInt(id);
        });
        if (itemIndex >= 0) { collection.splice(itemIndex, 1); }
      }
    },

    mounted() {
      this.timeZone = Vue.currentUser.timeZone;
      this.userId = Vue.currentUser.userId;
      this.$root.$on('esc-keyup', () => { this.showContact = false; });
      this.initConn();
    }
  };
</script>
<style lang="sass">

</style>
