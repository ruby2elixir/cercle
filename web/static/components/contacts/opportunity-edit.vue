<template>
  <div class="col-md-12">

    <div class="post" style="background-color:white;box-shadow: 0 1px 1px rgba(0,0,0,0.1);border-radius: 3px;padding:20px;margin-bottom:10px;">

      <button type="button" class="btn btn-default pull-right" v-on:click="archiveOpportunity" >ARCHIVE</button>

      <div style="" id="change_status">
        <span style="font-size:24px;color:rgb(150,150,150);"> <i class="fa fa-rocket" style="color:#d8d8d8;"></i>
          <span data-placeholder="Project Name" style="color:rgb(102,102,102);">
            <inline-edit v-model.lazy="opportunity.name" v-on:input="updateOpportunity" placeholder="Project Name"></inline-edit>
          </span>
        </span>
        <Br />
        <Br />
        <div style="margin-right:20px;margin-bottom:10px;">
          Managed by:
          <select v-model="opportunity.user_id"  v-on:change="updateOpportunity">
            <option v-for="user in company_users" :value="user.id">{{user.user_name}}</option>
          </select>
          &nbsp;&nbsp;
          Status:
          <select  v-model="opportunity.board_column_id" v-on:change="updateOpportunity">
            <option v-for="board_column in board_columns" :value="board_column.id">{{board_column.name}}</option>
          </select>
        </div>
        Contacts Involved:
        <a v-for="o_contact in opportunity_contacts" :href="'/contact/'+o_contact.id" class="o_contact">{{o_contact.name}}</a>

        <modal title="What is his name?" large :show.sync="openContactModal">
            <div slot="modal-body" class="modal-body">
            <input class="form-control" v-model="NewContactName" type="text" placeholder="Name of the Contact">
            </div>
            <div slot="modal-footer" class="modal-footer">
             <button type="button" class="btn btn-success" v-on:click="addContact">Add Contact</button>
            </div>
        </modal>
        <button type="button" class="btn btn-link add_o_contact" v-on:click="openContactModal = true" >
          <i class="fa fa-fw fa-plus"></i>Add ...
        </button>

            <div style="margin-top:10px;margin-bottom:10px;">
              Description
              <br />
              <div style="margin-top:10px;" data-placeholder="Write a description...">
                <inline-text-edit v-model="opportunity.description" v-on:input="updateOpportunity" placeholder="Write a description..." ></inline-text-edit>
              </div>
            </div>
      </div>
      <to-do
        :activities.sync="activities"
        :companyUsers="company_users"
        :contact="contact"
        :opportunity="opportunity"
        :company="company"
        :timeZone="time_zone"
        :currentUserId="current_user_id"
      >
        <comment_form slot="comment-form" :contact="contact" :opportunity="opportunity" />
        <timeline_events
          slot="timeline-events"
          :events="events"
          />
      </to-do>

    </div>
  </div>

</template>

<script>
  import InlineEdit from '../inline-common-edit.vue';
  import ToDo from './to-do-edit.vue';
  import CommentForm from './comment-form.vue';
  import TimelineEvents from './timeline-events.vue';
  import InlineTextEdit from '../inline-textedit.vue';

  export default {
    props: [
      'contact', 'time_zone', 'current_user_id',
      'activities', 'events', 'opportunity', 'company',
      'opportunities',
      'company_users', 'board',
      'board_columns', 'opportunity_contacts',
      'organization'
    ],
    data(){
      return {
        openContactModal: false
      };
    },
    methods: {
      addContact(){
        var url = '/api/v2/contact';
        var data = {
          name: this.NewContactName,
          user_id: this.opportunity.user_id
        };
        if (this.company) {
          data['company_id'] = this.company.id;
        }
        if (this.organization) {
          data['organization_id'] = this.organization.id;
        }
        this.$http.post(url, { contact: data }).then(resp => {
          var op_url = '/api/v2/opportunity/'+ this.opportunity.id;
          var contact_ids = [];
          this.opportunity_contacts.forEach(function(item) {
            contact_ids.push(item.id);
          });
          contact_ids.push(resp.data.data.id);
          this.$http.put(op_url,{opportunity:{ contact_ids: contact_ids}});
        });

        this.NewContactName = '';
        this.openContactModal = false;
      },

      archiveOpportunity() {
        var url = '/api/v2/opportunity/' + this.opportunity.id;
        this.$http.put(url, { opportunity: { status: '1'} });
      },
      updateOpportunity(){
        var url = '/api/v2/opportunity/' + this.opportunity.id;
        this.$http.put(url, { opportunity: this.opportunity });
      }

    },
    components: {
      'inline-edit': InlineEdit,
      'to-do': ToDo,
      'comment_form': CommentForm,
      'timeline_events': TimelineEvents,
      'inline-text-edit': InlineTextEdit,
      'v-select': vSelect.VueSelect,
      'modal': VueStrap.modal
    }

  };
</script>

<style lang="sass">
  a.o_contact  {
  font-weight:bold;
  display:inline-block;
  padding:3px;
  border-radius:5px;
  margin-right:7px;
  color:grey;
  text-decoration:underline;
  }
  .add_o_contact {
  font-size: small;
  font-weight:bold;
  display:inline-block;
  padding:3px;
  border-radius:5px;
  margin-right:7px;
  color:grey;
  &:hover {
  color:grey;
  box-shadow: none;
  }
  &:active {
  color:grey;
  box-shadow: none;
  }

  &:focus {
  color:grey;
  box-shadow: none;
  }
  }
</style>
