<template>
  <div class="add-contact">
    <div class="form-group">
      <contact-autocomplete @change="selectContact" />
    </div>
    <div class="form-group">
      <input type="email"
             v-model="contact.email"
             placeholder="Email"
             class="form-control"
             :disabled="isExistingContact"
             @change="contactChange" />
    </div>
    <div class="form-group">
      <input type="phone"
             v-model="contact.phone"
             placeholder="Phone"
             class="form-control"
             :disabled="isExistingContact"
             @change="contactChange" />
    </div>
  </div>
</template>

<script>
  import ContactAutocomplete from '../shared/contact-autocomplete.vue';
  export default {
    props: [],
    data: function() {
      return {
        isExistingContact: false,
        contact: {
          id: null,
          name: null,
          email: null,
          phone: null
        },
        searchedContacts: []
      };
    },
    components: {
      'v-select': vSelect.VueSelect,
      'contact-autocomplete': ContactAutocomplete
    },
    methods: {
      reset: function() {
        this.contact = {};
        this.searchedContacts = [];
        this.isExistingContact = false;
      },

      selectContact(data) {
        this.isExistingContact = !data.newContact;
        this.contact = data.contact;

        this.$emit('select-contact', {
          isExistingContact: this.isExistingContact,
          contact: this.contact
        });
      },

      contactChange() {
        this.$emit('select-contact', {
          existingContactId: this.existingContactId,
          contact: this.contact
        });
      },

      searchContacts(search, loading) {
        loading(true);
        this.$http.get('/api/v2/company/' + Vue.currentUser.companyId + '/contact', { params: { q: search }}).then(resp => {
          this.searchedContacts = resp.data.data;
          loading(false);
        });
      }
    },
    mounted: function() {
      this.$on('reset', function(options){
        this.reset();
      });
    }
  };
</script>
