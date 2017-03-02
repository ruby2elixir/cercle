<template>
  <div class="contact-edit">
    <div style="max-width:800px;margin: 0px auto;"  >
      <!-- Main content -->
      <section class="content" style="margin-top:20px;">
        <div class="row">
          <profile-edit v-bind:contact="contact" v-bind:tags="tags" v-on:update="updateContact" v-on:updateTags="updateTags" />
          <div class="col-md-6">
            <organization-edit v-bind:organization="organization" v-on:update="updateOrganization"  v-on:buildOrganization="buildOrganization" />
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
            organization: {},
            tags: {}

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
        updateContact(data) {
            this.contact = data
            var url = '/api/v2/contact/' + this.contact_id;
            $.ajax( url , { method: 'PUT', data: { contact: data }  });
            },

        updateOrganization(data){
            console.log('update org', data);
            this.organization = data
            var url = '/api/v2/contact/' + this.contact_id;
            //$.ajax( url , { method: 'PUT', data: { contact: data }  });
            },
        buildOrganization(){ this.organization = { name: '', website: '', description: '' } },
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
