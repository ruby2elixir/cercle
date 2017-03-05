<template>
  <div class="contact-edit">
    <div style="max-width:800px;margin: 0px auto;"  >
      <!-- Main content -->
      <section class="content" style="margin-top:20px;">
        <div class="row">
          <profile-edit
            :contact="contact"
            :tags="tags"
            v-on:update="updateContact"
            v-on:updateTags="updateTags"
            v-on:remove="removeContact" />
          <div class="col-md-6">
            <organization-edit
              :organization="organization"
              v-on:update="updateOrganization"
              v-on:build="buildOrganization"
              v-on:remove="removeOrganization" />
          </div><!-- /.col -->

        </div>

        <div class="row">
          <opportunity-edit />
        </div>

        <div class="row">
          <to-do />
        </div>
      </section>
    </div>
  </div>
</template>

<script>
import {Socket, Presence} from "phoenix"
import InlineEdit from "../inline-common-edit.vue"
import ProfileEdit from "./profile-edit.vue"
import OrganizationEdit from "./organization-edit.vue"
import OpportunityEdit from "./opportunity-edit.vue"
import ToDo from "./to-do-edit.vue"

export default {
    props: ['contact_id'],
    data() {
        return {
            socket: null,
            channel: null,
            contact: { },
            company: {},
            organization: null,
            tags: []

        }
    },
    components: {
        'inline-edit': InlineEdit,
        'profile-edit': ProfileEdit,
        'organization-edit': OrganizationEdit,
        'opportunity-edit': OpportunityEdit,
        'to-do': ToDo
    },
methods: {
        updateTags(data) {
          var tag_ids = data
          if (tag_ids.length  == 0) {
             var url = '/api/v2/contact/' + this.contact_id + '/delete_tags';
             $.ajax( url , { method: 'PUT', data: { company_id: '1' }  });
           } else {
             var url = '/api/v2/contact/' + this.contact_id + '/update_tags';
             $.ajax( url , { method: 'PUT', data: { tags: tag_ids, company_id: '1' }  });
           }
        },
        removeContact(){

        },
        updateContact(data) {
            this.contact = data
            var url = '/api/v2/contact/' + this.contact_id;
            $.ajax( url , { method: 'PUT', data: { contact: data }  });
            },

        updateOrganization(data){
            console.log('update org', data, this.organization.id);
            var vm = this;
            if (this.organization.id) { //update org
              var url = '/api/v2/organizations/' + vm.organization.id;
               $.ajax( url , {
               data: {organization: vm.organization},
               method: 'PUT',
              });

            } else { // new org
             $.ajax( '/api/v2/organizations' , {
               data: {organization: data},  method: 'POST',
               success: function(res){ console.log('res'); vm.organization = data }
            });
                   
            }
            

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
          this.$http.get('/current_user').then(resp => {
              localStorage.setItem('auth_token', resp.data.token)
              Vue.http.headers.common['Authorization'] = localStorage.getItem('auth_token');
            })
        },
        connectToSocket() {
            this.socket = new Socket("/socket", {params: {token: window.userToken}});
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

            });
        }
    },
    mounted(){
        this.connectToSocket();
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
