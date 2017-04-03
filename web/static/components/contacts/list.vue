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
        <td>{{contact.name}}</td>
        <td>{{contact.jobTitle}}</td>
        <td>{{contact.organization && contact.organization.name}}</td>
        <td>{{contact.email}}</td>
        <td>{{contact.phone}}</td>
        <td>
          <span v-for="tag in contact.tags">{{tag.name}} </span>
        </td>
        <td style="width:120px;">
          <span style="color:grey;font-size:14px;">{{contact.updatedAt | moment("from")}}</span>
        </td>
      </tr>
</tbody>
    </table>

     <modal large title="Edit contact" :show.sync="showContact">
      <div slot="modal-body" class="modal-body">
        <component
         keep-alive
         v-bind:is="contactView"
         :contact_id.sync="contact.id"
         :current_user_id="current_user_id"
         :user_image="user_image"
         :time_zone="time_zone"
        >
        <div slot="modal-footer" class="modal-footer"></div>
        </component>
      </div>
    </modal>
  </div>
</template>

<script>
import {Socket, Presence} from 'phoenix';
import moment from 'moment';
import ContactForm from './edit.vue';
export default {
  props: ['company_id', 'current_user_id', 'time_zone', 'user_image'],
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
      this.channel = this.socket.channel('companies:' + this.company_id, {});

      this.channel.join()
            .receive('ok', resp => {

            })
            .receive('error', resp => { console.log('Unable to join', resp); });

      this.loadContacts();
    },
    setAuthToken(){
      let vm = this;
      localStorage.setItem('auth_token', document.querySelector('meta[name="guardian_token"]').content);
      Vue.http.headers.common['Authorization'] = 'Bearer ' + localStorage.getItem('auth_token');
      vm.initConn();
    }
  },
  mounted(){
    this.setAuthToken();
  }
};
</script>
