<template>
  <div class="add-contact">
    <div class="form-group">
      <v-select v-model="contact.name"
                :debounce="250"
                :on-change="selectContact"
                :on-search="searchContacts"
                :options="searchedContacts"
                :taggable="true"
                placeholder="Full Name"
                label="name"><span slot="no-options"></span></v-select>
    </div>
    <div class="form-group">
      <input type="email" v-model="contact.email" placeholder="Email" class="form-control" :disabled="isExistingContact" @change="contactChange" />
    </div>
    <div class="form-group">
      <input type="phone" v-model="contact.phone" placeholder="Phone" class="form-control" :disabled="isExistingContact" @change="contactChange" />
    </div>
  </div>
</template>

<script>
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
      'v-select': vSelect.VueSelect
    },
    methods: {
      selectContact(con) {
        if(con && con.id) {
          this.isExistingContact = true;
          this.contact.id = con.id;
          this.contact.name = con.name;
          this.contact.firstName = con.firstName;
          this.contact.lastName = con.lastName;
          this.contact.email = con.email;
          this.contact.phone = con.phone;
        } else {
          this.isExistingContact = false;
          this.contact.id = null;
          this.contact.firstName = null;
          this.contact.lastName = null;
          this.contact.name = con;
          this.contact.email = null;
          this.contact.phone = null;
        }

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
        this.$http.get('/api/v2/contact', { params: { q: search }}).then(resp => {
          this.searchedContacts = resp.data.data;
          loading(false);
        });
      }
    },
    mounted: function() {
    }
  };
</script>
