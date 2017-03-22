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
                    v-on:remove="deleteContact" />
                </td>

                <td style="width:50%;padding:20px;vertical-align: top;">
                  <organization-edit
                    :organization="organization"
                    :contact="contact"
                    :company="company"
                    >
                    <li slot="menu"><a href="#"  v-on:click="deleteContact">Delete Contact</a></li>
                   </organization-edit>
                </td>
              </tr>
            </table>



          </div>
        </div>

        <div class="row">
          <div class="col-md-12">
            <div style="padding:15px;">
              <a v-for="opportunity in opportunities" :href="'/contact/'+contact.id + '/opportunity/' + opportunity.id" class="opportunity-tags">
                {{opportunity.name}}
              </a>
              <button v-show="!ShowAddCard" v-on:click="ShowAddCard=true" type="button" class="btn btn-link show-add-card-form">
               <i class="fa fa-fw fa-plus"></i>Create a card
              </button>
              <div v-show="ShowAddCard">
                Create a card into the board:
                <select v-model="NewBoard">
                  <option v-for="board in boards" :value="board">{{board.name}}</option>
                </select>
                &nbsp;&nbsp;
                <button type="button" v-on:click="addNewCard" >Add</button>
              </div>
            </div>
          </div>
        </div>

        <div class="row" v-if="opportunity">
          <opportunity-edit
            :time_zone="time_zone"
            :current_user_id="current_user_id"
            :organization="organization"
            :contact="contact"
            :company="company"
            :company_users="company_users"
            :board="board"
            :board_columns="board_columns"
            :opportunity="opportunity"
            :opportunities="opportunities"
            :opportunity_contacts="opportunity_contacts"
            :activities.sync="activities"
            :events="events"
            />

        </div>
      </section>
    </div>
  </div>
</template>

<script>
import {Socket, Presence} from 'phoenix';
import InlineEdit from '../inline-common-edit.vue';
import ProfileEdit from './profile-edit.vue';
import OrganizationEdit from './organization-edit.vue';
import OpportunityEdit from './opportunity-edit.vue';

export default {
  props: ['contact_id', 'current_user_id', 'time_zone'],
  data() {
    return {
      ShowAddCard: false,
      socket: null,
      channel: null,
      contact: { },
      company: {},
      company_users: [],
      organization: null,
      opportunity: null,
      opportunities: [],
      tags: [],
      activitites: [],
      events: [],
      board: null,
      boards: [],
      board_columns: [],
      opportunity_contacts: [],
      NewBoard: null

    };
  },
  components: {
    'inline-edit': InlineEdit,
    'profile-edit': ProfileEdit,
    'organization-edit': OrganizationEdit,
    'opportunity-edit': OpportunityEdit

  },
  methods: {
    addNewCard() {
      var url = '/api/v2/opportunity/';
      this.$http.post(url,
        { opportunity: {
          main_contact_id: this.contact.id,
          contact_ids: [this.contact.id],
          company_id: this.company.id,
          name: '',
          board_id: this.NewBoard.id,
          board_column_id: this.NewBoard.board_columns[0].id
        } }
          ).then(resp => {
            console.log('resp', resp.data);
          });
      this.NewBoard = null;
      this.ShowAddCard = false;
    },

    deleteContact: function(){
      console.log('delete contact');
    },

    setAuthToken(){
      var vm = this;
      localStorage.setItem('auth_token', document.querySelector('meta[name="guardian_token"]').content);
      Vue.http.headers.common['Authorization'] = 'Bearer ' + localStorage.getItem('auth_token');
      vm.connectToSocket();
    },
    connectToSocket() {
      this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
      this.socket.connect();
      this.channel = this.socket.channel('contacts:' + this.contact_id, {});
      this.channel.join()
                .receive('ok', resp => {
                  this.channel.push('load_state');
                })
                .receive('error', resp => { console.log('Unable to join', resp); });
      this.channel.on('activity:created', payload => {
        this.activities.unshift(payload.activity);
      });

      this.channel.on('activity:deleted', payload => {
        var index = this.activities.findIndex(function(item){
          return item.id === payload.activity_id;
        });
        this.activities.splice(index, 1);
      });

      this.channel.on('activity:updated', payload => {
        var index = this.activities.findIndex(function(item, index){
          return item.id === payload.activity.id;
        });
        this.activities.splice(index, 1, payload.activity);
      });

      this.channel.on('timeline_event:created', payload => {
        this.events.unshift(payload.event);
      });

      this.channel.on('opportunity:updated', payload => {
        if (payload.opportunity) {
          this.opportunity = payload.opportunity;
          this.opportunity_contacts = payload.opportunity_contacts;
        }
        if (payload.board) {
          this.board = payload.board;
          this.board_columns = payload.board_columns;
        }
      });

      this.channel.on('state', payload => {
        this.contact = payload.contact;
        if (payload.boards) {
          this.boards = payload.boards;
        }
        if (payload.opportunity) {
          this.opportunity = payload.opportunity;
          this.opportunity_contacts = payload.opportunity_contacts;
        }

        if (payload.opportunities) {
          this.opportunities = payload.opportunities;
        }
        if (payload.company) {
          this.company = payload.company;
          this.company_users = payload.company_users;
        }
        if (payload.tags) {
          this.tags = payload.tags;
        }
        if (payload.organization) {
          if (payload.organization['id']) {
            this.organization = payload.organization;
          } else {
            this.organization = null;
          }
        }
        if (payload.activities) {
          this.activities = payload.activities;
        }
        if (payload.events) {
          this.events = payload.events;
        }
        if (payload.board) {
          this.board = payload.board;
          this.board_columns = payload.board_columns;
        }

      });
    }
  },
  mounted(){
    this.setAuthToken();

  }
};
</script>

<style lang="sass">
.contact-edit {
margin-left: auto;
margin-right: auto;
width: 800px;

h1 {
text-align: center;
}
.show-add-card-form {
font-weight:bold;display:inline-block;padding:0px 3px 3px 3px;border-radius:5px;margin-right:7px;color:grey;text-decoration:underline;
}
.opportunity-tags {
font-weight:bold;padding:3px;border-radius:5px;margin-right:7px;color:grey;text-decoration:underline;
}
}
</style>
