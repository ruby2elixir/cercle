<script>
  import {Socket, Presence} from 'phoenix';
  import InlineEdit from '../inline-common-edit.vue';
  import CardShow from '../cards/show.vue';
  import ActivityItem from './item.vue';

  export default {
    data() {
      return {
        timeZone: null,
        contact: {},
        card: {},
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
      'card-show': CardShow,
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
      cardShow(cardId) {
        this.card = { id: cardId };
        this.$glmodal.$emit(
         'open', {
           view: 'card-show', class: 'card-modal', data: { 'cardId': cardId }
         });

      },
      initConn() {
        let url = '/api/v2/company/' + Vue.currentUser.companyId + '/activity';
        this.$http.get(url, { params: { userId: Vue.currentUser.userId }}).then(resp => {
          this.activities = resp.data.activities;
        });

        this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
        this.socket.connect();
        this.channel = this.socket.channel('users:' + this.userId, {});

        this.channel.join()
              .receive('ok', resp => {  })
              .receive('error', resp => { console.log('Unable to join', resp); });

        this.channel.on('activity:deleted', payload => {
          let _payload = this.camelCaseKeys(payload);
          this.deleteItem(this.activities, _payload.activityId);
        });

        this.channel.on('activity:created', payload => {
          let _payload = this.camelCaseKeys(payload);
          this.$data.activities.push(_payload.activity);
        });

        this.channel.on('activity:updated', payload => {
          let _payload = this.camelCaseKeys(payload);
          this.updateItem(this.activities, _payload.activity);
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
      this.initConn();
    }
  };
</script>
<style lang="sass">

</style>
