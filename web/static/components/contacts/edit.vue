<template>
  <div class="contact-edit">
    <div style="max-width:800px;margin: 0px auto;"  >
      <!-- Main content -->
      <section class="content" style="margin-top:20px;">
        <div class="row">
          <div class="col-md-12">
            <table style="width:100%;background-color:white;">
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
        <div class="row" v-if="browseOpportunities">
          <div class="col-md-12">
          <div style="padding:15px;background-color:#EDF0F5;">
              <div v-for="opp in opportunities" v-on:click="changeOpportunity(opp)" class="opportunity-tags">
                {{opp.name}}
              </div>
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

        <div class="row" v-if="opportunity && !browseOpportunities">

          <opportunity-edit
            ref="opportunityEdit"
            :time_zone="time_zone"
            :current_user_id="current_user_id"
            :organization="organization"
            :contact="contact"
            :company="company"
            :company_users="company_users"
            :opportunity="opportunity"
            :opportunities="opportunities"
            v-on:browse="browseOpportunities = true"
            :socket="socket"
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
      opportunity_channel: null,
      contact: { },
      company: {},
      company_users: [],
      organization: null,
      opportunity: null,
      opportunities: [],
      tags: [],
      activities: [],
      events: [],
      board: null,
      boards: [],
      board_columns: [],
      opportunity_contacts: [],
      NewBoard: null,
      browseOpportunities: true

    };
  },
  components: {
    'inline-edit': InlineEdit,
    'profile-edit': ProfileEdit,
    'organization-edit': OrganizationEdit,
    'opportunity-edit': OpportunityEdit

  },
  methods: {
    changeOpportunity(opp) {
      this.browseOpportunities = false;
      this.opportunity = opp;
      return false;
    },
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
        } });
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


      this.channel.on('opportunity:created', payload => {
        if (payload.opportunity) {
          this.opportunities.push(payload.opportunity);
          this.opportunity || (this.opportunity = payload.opportunity);
        }
      });

      this.channel.on('state', payload => {
        this.contact = payload.contact;
        if (payload.boards) {
          this.boards = payload.boards;
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
.opportunity-tags {
cursor:pointer;
font-weight:bold;
color:grey;
font-size:15px;
vertical-align: top;
background-color:white;
display:inline-block;
width:120px;
height:120px;
padding:15px;
margin-right:10px;
}
h1 {
text-align: center;
}
.btn-link {
  font-weight:bold;
  display:inline-block;
  padding:0px 3px 3px 3px;
  border-radius:5px;
  margin-right:7px;
  color:grey;
  text-decoration:underline;
&:active {

    box-shadow: none;
    border: none;
    outline: none;
    }
    &:focus {
    box-shadow: none;
    border: none;
    outline: none;
    }
}
.show-add-card-form {
font-weight:bold;display:inline-block;padding:0px 3px 3px 3px;border-radius:5px;margin-right:7px;color:grey;text-decoration:underline;
}
.opportunity-tags {
font-weight:bold;padding:3px;margin-right:17px;color:grey;text-decoration:underline;
}
}
</style>
