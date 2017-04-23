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
        var jwtToken = document.querySelector('meta[name="guardian_token"]').content;
        if(data.name !== ''){
          $.ajax('/api/v2/contact', {
            method: 'POST',
            data: {
              'contact[user_id]': userId,
              'contact[company_id]': companyId,
              'contact[name]': data.name,
              'contact[email]': data.email,
              'contact[phone]': data.phone
            },
            headers: {'Authorization': 'Bearer '+jwtToken},
            success: function(result){
              var contactId = result.data.id;
              $.ajax( '/api/v2/opportunity/' , {
                method: 'POST',
                headers: {'Authorization': 'Bearer '+jwtToken},
                data: {
                  'opportunity[main_contact_id]': contactId ,
                  'opportunity[contact_ids]': [contactId],
                  'opportunity[user_id]': userId,
                  'opportunity[company_id]': companyId,
                  'opportunity[board_id]': boardId,
                  'opportunity[board_column_id]': data.column,
                  'opportunity[name]': ''
                },
                complete: function(xhr, status){
                  window.location.reload();
                }
              });
            }
          });
        }else{
          alert('Name can\'t be blank');
        }
      }
    },
    mounted() {
      this.$root.$on('esc-keyup', () => { this.showContact = false; });
    }
  };
</script>
<style lang="sass">

</style>
