<template>
  <div class="contact-edit">
    <div style="max-width:800px;margin: 0px auto;"  >
      <!-- Main content -->
      <section class="content" style="margin-top:20px;">
        <div class="row">
          <div class="col-md-12">
            <table style="width:100%;background-color:white;margin-bottom:40px;">
              <tr>
                <td style="width:50%;padding:20px;vertical-align: top;">
                  <profile-edit
                    :contact="contact"
                    :tags="tags"
                    v-on:update="updateContact"
                    v-on:updateTags="updateTags"
                    v-on:remove="removeContact" />
                </td>
                <td style="width:50%;padding:20px;vertical-align: top;">
                  <organization-edit
                    :organization="organization"
                    v-on:update="updateOrganization"
                    v-on:build="buildOrganization"
                    v-on:remove="removeOrganization"
                    v-on:choose="chooseOrganization"
                    v-on:add_new="addNewOrganization"
                    >
                    <li slot="menu"><a href="#"  v-on:click="deleteContact">Delete Contact</a></li>
                   </organization-edit>
                </td>
              </tr>
            </table>



          </div>
        </div>

        <div class="row">
          <opportunity-edit
            :activities="activities"
            :events="events"
            />
        </div>
      </section>
    </div>
  </div>
</template>
<!-- <li slot="menu"><a href="#" v-on:click="deleteContact">Delete Contact</a></li> -->
<script>
import {Socket, Presence} from "phoenix"
import InlineEdit from "../inline-common-edit.vue"
import ProfileEdit from "./profile-edit.vue"
import OrganizationEdit from "./organization-edit.vue"
import OpportunityEdit from "./opportunity-edit.vue"

export default {
    props: ['contact_id'],
    data() {
        return {
            socket: null,
            channel: null,
            contact: { },
            company: {},
            organization: null,
            tags: [],
            activitites: [],
            events: []

        }
    },
    components: {
        'inline-edit': InlineEdit,
        'profile-edit': ProfileEdit,
        'organization-edit': OrganizationEdit,
        'opportunity-edit': OpportunityEdit
    },
      methods: {
        deleteContact: function(){
         console.log('delete contact');
        },

        updateTags(data) {
          var tag_ids = data
          if (tag_ids.length  == 0) {
             var url = '/api/v2/contact/' + this.contact_id + '/utags';
             this.$http.put(url,
              { company_id: this.contact.company_id }
             )
           } else {
             var url = '/api/v2/contact/' + this.contact_id + '/update_tags';
             this.$http.put(url,
              { tags: tag_ids, company_id: this.contact.company_id }
             )
           }
        },
        removeContact(){

        },
        updateContact(data) {
            this.contact = data
            var url = '/api/v2/contact/' + this.contact_id;
            $.ajax( url , { method: 'PUT', data: { contact: data }  });
            },

        chooseOrganization(data){
            var vm = this;
              var url = '/api/v2/contact/' + vm.contact.id;
              this.$http.put(url, { contact: { organization_id: data.id }}).then(resp => {
              vm.organization = data
              })
        },

        addNewOrganization(data){
          var vm = this;
          var url = '/api/v2/organizations';
          this.$http.post(url, { organization: { name: data.name, company_id: vm.company.id }}).then(resp => {
            vm.chooseOrganization(resp.data.data)
          })

        },

        updateOrganization(data){
          var vm = this;
          var url = '/api/v2/organizations/' + vm.organization.id;
            $.ajax( url , {
              data: { contact_id: vm.contact.id, organization: vm.organization},
              method: 'PUT',
             });
        },

        buildOrganization(){ this.organization = { name: '', website: '', description: '' } },
        removeOrganization() {
          var vm = this;
          var url = '/api/v2/contact/' + vm.contact.id;
            $.ajax( url , {
              method: 'PUT',
              data: { 'contact[organization_id]': '' },
              complete: function(xhr, status){ vm.organization = null
              }
            });

        },
        setAuthToken(){
          var vm = this
          vm.$http.get('/current_user').then(resp => {
              localStorage.setItem('auth_token', resp.data.token)
              Vue.http.headers.common['Authorization'] = localStorage.getItem('auth_token');
              vm.connectToSocket();
            })
        },
        connectToSocket() {
            this.socket = new Socket("/socket", {params: { token: localStorage.getItem('auth_token') }});
            this.socket.connect();
            this.channel = this.socket.channel("contacts:" + this.contact_id, {});
            this.channel.join()
                .receive("ok", resp => {
                    this.channel.push("load_state");
                })
                .receive("error", resp => { console.log("Unable to join", resp) });
                this.channel.on('state', payload => {
                this.contact = payload.contact
                if (payload.company) {
                    this.company = payload.company
                }
                if (payload.tags) {
                    this.tags = payload.tags
                }
                if (payload.organization) {
                    this.organization = payload.organization
                    }
                if (payload.activities) {
                    this.activities = payload.activities
                }
                if (payload.events) {
                    this.events = payload.events
                }

            });
        }
    },
    mounted(){
        this.setAuthToken();

    }
}
  </script>

<style lang="sass">
.contact-edit {
margin-left: auto;
margin-right: auto;
width: 800px;

h1 {
text-align: center;
}
}
</style>
