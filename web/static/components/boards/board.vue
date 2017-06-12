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
        contact: {},
        card: {}
      };
    },
    components: {
      'inline-edit': InlineEdit,
      'modal': VueStrap.modal,
      'contact-form': ContactForm,
      'new-contact': NewContact
    },
    methods: {
      newContact(boards, company_id) {
        this.$glmodal.$emit(
              'open', {
                view: 'new-contact-form',
                class: 'new-contact-modal',
                title: 'Add a contact into this board',
                closed_in_header: true,
                size: 'small',
                display_header: true,
                data: {
                  board_id: this.board_id,
                  'default-board-id': this.board_id,
                  'user-id': Vue.currentUser.userId,
                  'company-id': company_id,
                  boards: boards
                }
              });
      },
      contactShow(contactId, cardId) {
        this.contact = {id: contactId};
        this.card = { id: cardId };
        this.$glmodal.$emit(
          'open', {
            view: 'contact-form', class: 'contact-modal', data: { card_id: cardId, contact_id: contactId }
          });
      },
      changeContactDisplay(contactId) {
        this.contact = {id: contactId};
      }
    },
    mounted() {
    }
  };
</script>
<style lang="sass">

</style>
