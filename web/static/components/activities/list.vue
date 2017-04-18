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
        opportunity: {},
        contactView: null,
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
      contactShow(contactId, opportunityId) {
        this.showContact = null;
        this.contact = {id: contactId};
        this.opportunity = { id: opportunityId };
        this.contactView = 'contact-form';
        this.showContact = true;
      },
      initConn() {
        this.$http.get('/api/v2/activity').then(resp => {
          this.activitiesOverdue = resp.data.activities.overdue;
          this.activitiesToday = resp.data.activities.today;
          this.activitiesLater = resp.data.activities.later;
        });

        this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
        this.socket.connect();
        this.channel = this.socket.channel('users:' + this.userId, {});

        this.channel.join()
              .receive('ok', resp => {  })
              .receive('error', resp => { console.log('Unable to join', resp); });

        this.channel.on('activity:deleted', payload => {
          this.deleteItem(this.activitiesOverdue, payload.activity_id);
          this.deleteItem(this.activitiesToday, payload.activity_id);
          this.deleteItem(this.activitiesLater, payload.activity_id);
        });

        this.channel.on('activity:created', payload => {
          this.$data.activitiesToday.unshift(payload.activity);
        });

        this.channel.on('activity:updated', payload => {
          this.updateItem(this.activitiesOverdue, payload.activity);
          this.updateItem(this.activitiesToday, payload.activity);
          this.updateItem(this.activitiesLater, payload.activity);
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
      },
      setAuthToken(){
        var vm = this;
        localStorage.setItem('auth_token', document.querySelector('meta[name="guardian_token"]').content);
        Vue.http.headers.common['Authorization'] = 'Bearer ' + localStorage.getItem('auth_token');
        vm.initConn();
      }},
    mounted() {
      this.timeZone = document.querySelector('meta[name="time_zone"]').content;
      this.userId = document.querySelector('meta[name="user_id"]').content;
      this.setAuthToken();
    }
  };
</script>
<style lang="sass">

</style>
