<template>
  <div class="list">
    <table class="table table-bordered">
     <tbody>
      <tr>
        <th>Name</th>
        <th>Job Title</th>
        <th>Organization</th>
        <th>Email</th>
        <th>Phone</th>
        <th>Tags</th>
        <th>Last Updated</th>
      </tr>
      <tr v-for="contact in contacts" v-on:click="contactShow(contact)">
        <td>{{contact.first_name}} {{contact.last_name}}</td>
        <td>{{contact.job_title}}</td>
        <td>{{contact.organization && contact.organization.name}}</td>
        <td>{{contact.email}}</td>
        <td>{{contact.phone}}</td>
        <td>
          <span v-for="tag in contact.tags">{{tag.name}} </span>
        </td>
        <td style="width:120px;">
          <span style="color:grey;font-size:14px;">{{contact.updated_at | moment("from")}}</span>
        </td>
      </tr>
</tbody>
    </table>
  </div>
</template>

<script>
import {Socket, Presence} from 'phoenix';
import moment from 'moment';
import ContactForm from './edit.vue';
export default {
  props: ['company_id'],
  data() {
    return {
      contacts: [],
      socket: null,
      channel: null,
      contact: {},
    };
  },
  components: {
    'modal': VueStrap.modal,
    'contact-form': ContactForm
  },
  methods: {
    contactShow(contact) {
      this.contact = contact;
      this.$glmodal.$emit(
        'open', {
          view: 'contact-form', class: 'contact-modal', data: { contact_id: contact.id }
        });
    },
    loadContacts(){
      var url = '/api/v2/contact';
      this.$http.get(url,  { }).then(resp => {
        this.contacts = resp.data.data;
      });

    },
    initConn(){

      this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
      this.socket.connect();
      this.loadContacts();
    },
    setAuthToken(){
      let vm = this;
      vm.initConn();
    }
  },
  mounted(){
    this.setAuthToken();
  }
};

</script>
<style lang="sass">
.contact-modal {
  .modal-header {
    border: none;
    }
  button.close {
    position: absolute;right: 10px;top: 4px; z-index: 999;
  }
}
</style>
