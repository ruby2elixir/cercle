<script>
  import {Socket, Presence} from 'phoenix';
  import InlineEdit from '../inline-common-edit.vue';
  import ContactForm from '../contacts/edit.vue';
  import NewContact from './new-contact.vue';

  export default {
    props: ['board_id'],
    data() {
      return {
        board: {},
        newContact: false,
        showContact: false,
        contact: {},
        opportunity: {},
        contactView: null
      };
    },
    components: {
      'inline-edit': InlineEdit,
      'modal': VueStrap.modal,
      'contact-form': ContactForm,
      'new-contact': NewContact
    },
    methods: {
      contactShow(contactId, opportunityId) {
        this.showContact = null;
        this.contact = {id: contactId};
        this.opportunity = { id: opportunityId };
        this.contactView = 'contact-form';
        this.showContact = true;
      },

      createContact(userId, companyId, data) {
        var boardId = this.board_id;
      }
    },
    mounted() {
      this.$root.$on('esc-keyup', () => { this.showContact = false; });
    }
  };
</script>
<style lang="sass">

</style>
