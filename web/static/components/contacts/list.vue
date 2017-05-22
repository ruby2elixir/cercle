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

     <modal large :show.sync="showContact" class="contact-modal">
      <span slot="modal-header"></span>
      <div slot="modal-body" class="modal-body">
        <button type="button" class="close" @click="showContact=false">
          <span>&times;</span>
        </button>
        <component
         keep-alive
         v-bind:is="contactView"
         :contact_id.sync="contact.id"
        >

        </component>
      </div>
      <span slot="modal-footer"></span>
    </modal>
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
      showContact: false,
      contact: {},
      contactView: null

    };
  },
  components: {
    'modal': VueStrap.modal,
    'contact-form': ContactForm
  },
  methods: {
    contactShow(contact) {
      this.showContact = null;
      this.contact = contact;
      this.contactView = 'contact-form';
      this.showContact = true;
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
    this.$root.$on('esc-keyup', () => { this.showContact = false; });
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
