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
        activitiesToday: []
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
      },
      setAuthToken(){
        var vm = this;
        localStorage.setItem('auth_token', document.querySelector('meta[name="guardian_token"]').content);
        Vue.http.headers.common['Authorization'] = 'Bearer ' + localStorage.getItem('auth_token');
        vm.initConn();
      }},
    mounted() {
      this.timeZone = document.querySelector('meta[name="time_zone"]').content;
      this.setAuthToken();
    }
  };
</script>
<style lang="sass">

</style>
