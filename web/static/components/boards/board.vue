<script>
  import {Socket, Presence} from 'phoenix';
  import InlineEdit from '../inline-common-edit.vue';
  import ContactForm from '../contacts/edit.vue';
  import NewContact from '../contacts/new.vue';

  export default {
    props: ['board_id'],
    data() {
      return {
        board: {},
        newContact: false,
        showContact: false,
        contact: {},
        card: {},
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
      contactShow(contactId, cardId) {
        this.showContact = null;
        this.contact = {id: contactId};
        this.card = { id: cardId };
        this.contactView = 'contact-form';
        this.showContact = true;
      },
      changeContactDisplay(contactId) {
        this.contact = {id: contactId};
      }
    },
    mounted() {
      this.$root.$on('esc-keyup', () => { this.showContact = false; });
    }
  };
</script>
<style lang="sass">

</style>
