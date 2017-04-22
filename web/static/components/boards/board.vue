<script>
  import {Socket, Presence} from 'phoenix';
  import InlineEdit from '../inline-common-edit.vue';
  import ContactForm from '../contacts/edit.vue';
  import NewCard from './new-card.vue';

  export default {
    props: ['board_id'],
    data() {
      return {
        board: {},
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
      'new-card': NewCard
    },
    methods: {
      contactShow(contactId, opportunityId) {
        this.showContact = null;
        this.contact = {id: contactId};
        this.opportunity = { id: opportunityId };
        this.contactView = 'contact-form';
        this.showContact = true;
      },

      showNewCard(colId) {
        $('.column_master[data-id='+colId+'] .new-card').show();
      },

      hideNewCard(colId) {
        $('.column_master[data-id='+colId+'] .new-card').hide();
      },

      addContact(userId, companyId, colId, data) {
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
                  'opportunity[board_column_id]': colId,
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
