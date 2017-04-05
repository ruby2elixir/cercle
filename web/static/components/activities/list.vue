<script>
  import {Socket, Presence} from 'phoenix';
  import InlineEdit from '../inline-common-edit.vue';
  import ContactForm from '../contacts/edit.vue';

  export default {
    data() {
      return {
        showContact: false,
        contact: {},
        opportunity: {},
        contactView: null
      };
    },
    components: {
      'inline-edit': InlineEdit,
      'modal': VueStrap.modal,
      'contact-form': ContactForm
    },
    methods: {
      contactShow(contactId, opportunityId) {
        this.showContact = null;
        this.contact = {id: contactId};
        this.opportunity = { id: opportunityId };
        this.contactView = 'contact-form';
        this.showContact = true;
      }
    },
    mounted() {
    }
  };
</script>
<style lang="sass">

</style>
