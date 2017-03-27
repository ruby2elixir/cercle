<template>
  <div class="col-md-12">
    <div class="post" style="background-color:white;padding:20px;margin-bottom:10px;padding-top: 0px;" v-if="item">
    <div class="pull-right">
      <button type="button" class="btn btn-primary pull-right" v-on:click="$emit('browse')"  style="margin-top:10px;margin-right:10px;width:110px;" >BROWSE</button>
      <br />
      <button type="button" class="btn btn-default " v-on:click="archiveOpportunity" style="margin-top:10px;margin-right:10px;width:110px;" >ARCHIVE</button>
    </div>
      <div style="" id="change_status">
        <span style="font-size:24px;color:rgb(150,150,150);"> <i class="fa fa-rocket" style="color:#d8d8d8;"></i>
          <span data-placeholder="Project Name" style="color:rgb(102,102,102);">
            <inline-edit v-model="item.name" v-on:input="updateOpportunity" placeholder="Project Name"></inline-edit>
          </span>
        </span>
        <br />
        <br />
        <div style="margin-right:20px;margin-bottom:10px;">
          Managed by:
          <select v-model="item.user_id"  v-on:change="updateOpportunity">
            <option v-for="user in company_users" :value="user.id">{{user.user_name}}</option>
          </select>
          &nbsp;&nbsp;
          Status:
          <select  v-model="item.board_column_id" v-on:change="updateOpportunity">
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
               <inline-text-edit v-model="item.description" v-on:input="updateOpportunity" placeholder="Write a description..." ></inline-text-edit>
              </div>
            </div>
      </div>
      <to-do
        :activities="activities"
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
      'socket',
      'contact', 'time_zone', 'current_user_id',
      'opportunity', 'company',
      'opportunities',
      'company_users',
      'organization'
    ],
    data(){
      return {
        openContactModal: false,
        allowUpdate: true,
        item: this.opportunity,
        items: this.opportunities,
        contacts: this.opportunity_contacts,
        board_columns: [],
        board: {},
        opportunity_channel: null,
        activities: [],
        events: [],
        opportunity_contacts: []

      };
    },
    methods: {
      addContact(){
        let url = '/api/v2/contact';
        let data = {
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
          let op_url = '/api/v2/opportunity/'+ this.opportunity.id;
          let contact_ids = [];
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
        let url = '/api/v2/opportunity/' + this.item.id;
        this.$http.put(url, { opportunity: { status: '1'} });
      },
      updateOpportunity(){
        if (this.allowUpdate) {
          let url = '/api/v2/opportunity/' + this.item.id;
          this.$http.put(url, { opportunity: this.item });
        }
      },


      subscribe() {

        this.opportunity_channel.on('load', payload => {
          if (payload.activities) {
            this.$data.activities = payload.activities;
          }
          if (payload.board) {
            this.$data.board = payload.board;
            this.$data.board_columns = payload.board_columns;
          }

          if (payload.events) {
            this.$data.events = payload.events;
          }

          if (payload.opportunity) {
            this.$data.item = payload.opportunity;
          }
          if (payload.opportunity_contacts) {
            this.$data.opportunity_contacts = payload.opportunity_contacts;
          }
          this.allowUpdate = true;
        });

        this.opportunity_channel.on('opportunity:closed', payload => {
          if (payload.opportunity) {
            let item_index = this.opportunities.findIndex(function(item){
              return item.id === payload.opportunity.id;
            });
            this.$data.items.splice(item_index,1);
            if (this.$data.items.length === 0) {
              this.clearOpportunity();
            } else if (this.$data.item.id === payload.opportunity.id) {
              this.setOpportunity(this.$data.items[0]);
            }

          }
        });
        this.opportunity_channel.on('opportunity:updated', payload => {
          if (payload.opportunity) {
            this.$data.item = payload.opportunity;
            this.$data.opportunity_contacts = payload.opportunity_contacts;

            let item_index = this.opportunities.findIndex(function(item){
              return item.id === payload.opportunity.id;
            });

            this.$data.items.splice(item_index, 1, payload.opportunity);
          }
          if (payload.board) {
            this.$data.board = payload.board;
            this.$data.board_columns = payload.board_columns;
          }
        });


        this.opportunity_channel.on('activity:created', payload => {
          this.$data.activities.unshift(payload.activity);
        });

        this.opportunity_channel.on('activity:deleted', payload => {
          let item_index = this.$data.activities.findIndex(function(item){
            return item.id === payload.activity_id;
          });
          this.$data.activities.splice(item_index, 1);
        });

        this.opportunity_channel.on('activity:updated', payload => {
          let item_index = this.$data.activities.findIndex(function(item){
            return item.id === payload.activity.id;
          });
          this.$data.activities.splice(item_index, 1, payload.activity);
        });

        this.opportunity_channel.on('timeline_event:created', payload => {
          this.$data.events.unshift(payload.event);
        });


      },
      leaveChannel() {
        if (this.opportunity_channel) { this.opportunity_channel.leave(); }
      },
      initChannel(){
        if (this.opportunity_channel) {
          this.opportunity_channel.leave().receive('ok', () => {
            this.opportunity_channel = this.socket.channel('opportunities:' + this.opportunity.id, {});
            this.subscribe();
            this.opportunity_channel.join()
              .receive('ok', resp => {
                this.opportunity_channel.push('load', {contact_id: this.contact.id});
              }).receive('error', resp => {  });


          });
        } else {
          this.opportunity_channel = this.socket.channel('opportunities:' + this.opportunity.id, {});
          this.subscribe();
          this.opportunity_channel.join()
            .receive('ok', resp => {
              this.opportunity_channel.push('load', { contact_id: this.contact.id });
            }).receive('error', resp => {  });
        }
      },

      clearOpportunity() {
        this.allowUpdate = false;
        this.$data.item = null;
        this.leaveChannel();
      },
      setOpportunity(opp) {
        this.allowUpdate = false;
        this.$data.item = opp;
        this.initChannel();
      }
    },
    watch: {
      opportunity() {
        this.allowUpdate = false;
        this.$data.item = this.opportunity;

        if (this.opportunity){
          this.initChannel();
        } else { this.leaveChannel(); }
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
    },


    mounted() {
      this.initChannel();
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
