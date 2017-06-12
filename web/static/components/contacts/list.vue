<template>
  <div>

    <!-- Content Header (Page header) -->
    <section class="content-header" style="margin-top:20px;margin-bottom:20px;">


      <h2>People<br /> <span style="font-size:16px;color:grey;">{{contacts.length}} contacts</span></h2>

      <div class="row">
        <div class="col-xs-10">

          <form class="navbar-form" role="search" v-on:submit.prevent>
            <div class="input-group add-on">
              <input class="form-control" placeholder="Search" name="q" type="text" v-model="searchTerm" />
              <div class="input-group-btn">
                <button class="btn btn-default" type="submit" v-on:click.stop.prevent="searchContacts"><i class="glyphicon glyphicon-search"></i></button>
              </div>
            </div>
          </form>
        </div>

        <div class="col-xs-2">
          <a href="/contact/new" class="btn btn-primary">+ Add a Contact</a>
        </div>
      </div>
    </section>


    <!-- Main content -->
    <section class="content">
      <div class="row">
        <div class="col-xs-12">
          <div class="box" style="border:0px solid grey;">

            <!-- /.box-header -->
            <div class="nav-tabs-custom ">

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

            </div><!-- /.box-body -->
          </div><!-- /.box -->
        </div>
      </div>

    </section><!-- /.content -->
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
        searchTerm: ''
      };
    },
    components: {
      'modal': VueStrap.modal,
      'contact-form': ContactForm
    },

    methods: {
      searchContacts() {
        let params = {};
        if (this.searchTerm !== '') {
          params = { q: this.searchTerm };
        }
        this.loadContacts(params);
      },
      contactShow(contact) {
        this.contact = contact;
        this.$glmodal.$emit(
  'open', {
    view: 'contact-form', class: 'contact-modal', data: { contact_id: contact.id }
  });
      },
      loadContacts(opts){
        let url = '/api/v2/contact';
        let params = opts || {};
        this.$http.get(url, { params: params }).then(resp => {
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
