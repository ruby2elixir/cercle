<template>
  <div class="contact-edit">
    <div style=""  >
      <!-- Main content -->
      <section>
        <div class="row">
          <div class="col-md-12">
            <table style="width:100%;background-color: #edf0f5;">
              <tr>
                <td style="width:50%;padding:20px;vertical-align: top;padding-right:0px;">
                  <profile-edit
                    :contact="contact"
                    :tags="tags" />
                  <delete-contact :contact="contact" v-if="!(card && !browseCards)"></delete-contact>
                </td>

                <td style="width:50%;padding:20px;vertical-align: top;">
                  <organization-edit
                    :organization="organization"
                    :contact="contact"
                    :company="company"
                    v-on:updateOrganization="updateOrganization"
                    >
                   </organization-edit>
                </td>
              </tr>
            </table>
          </div>
        </div>
        <div class="row" v-if="browseCards">

          <div class="col-md-12">
          <div style="padding:15px;background-color:#EDF0F5;">
              <div v-for="card in cards" v-on:click="changeCard(card)" class="card-tags">
                {{cardName(card)}}
              </div>
              <button v-show="!showAddCard" v-on:click="showAddCard=true" type="button" class="btn btn-link show-add-card-form">
               <i class="fa fa-fw fa-plus"></i>Insert this contact into a board
              </button>

              <button type="button" class="btn btn-link" v-on:click="showArchivedCard=!showArchivedCard">
              <i class="fa fa-fw " :class="[showArchivedCard ? 'fa-eye-slash' : 'fa-eye']"></i>
               <span>{{showArchivedCard ? 'Hide' : 'Show'}} Archived card</span>
              </button>

              <div v-show="showAddCard">
                Insert the contact into the board:
                <select v-model="newBoard">
                  <option v-for="board in boards" :value="board">{{board.name}}</option>
                </select>
                &nbsp;&nbsp;
                <button type="button" v-on:click="addNewCard" >Add</button>
              </div>
            </div>
          </div>
        </div>

        <div class="row" v-if="card && !browseCards">
          <card-edit
            ref="cardEdit"
            :time_zone="timeZone"
            :organization="organization"
            :contact="contact"
            :company="company"
            :company_users="companyUsers"
            :card="card"
            :cards="cards"
            :user_image="userImage"
            v-on:browse="browseCards = true"
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
import CardEdit from './card-edit.vue';
import DeleteContact from './delete.vue';

export default {

  props: ['contact_id', 'card_id'],
  data() {
    return {
      showAddCard: false,
      showArchivedCard: false,
      socket: null,
      channel: null,
      contact: { },
      company: {},
      companyUsers: [],
      organization: null,
      card: null,
      cards: [],
      tags: [],
      activities: [],
      events: [],
      board: null,
      boards: [],
      boardColumns: [],
      newBoard: null,
      browseCards: true,
      timeZone: null,
      userImage: null
    };
  },
  watch: {
    'contact_id': function() {
      this.initConn(true);
    },
    'showArchivedCard': function(){
      this.$http.get('/api/v2/card/', { params: { contactId: this.contact.id, archived: this.showArchivedCard }}).then(resp => {
        this.cards = resp.data.data;
      });
    }
  },
  components: {
    'inline-edit': InlineEdit,
    'profile-edit': ProfileEdit,
    'organization-edit': OrganizationEdit,
    'card-edit': CardEdit,
    'delete-contact': DeleteContact
  },
  methods: {
    updateOrganization(org) {
      this.organization = org;

      let cardDisplayHtml = this.contact.first_name + ' ' + this.contact.last_name;
      if(this.organization) {
        cardDisplayHtml += ' <span style="color:rgb(119, 119, 119);"> - ' +this.organization.name+ '</span>';
      }
      $('.portlet[data-id=' +this.card_id+ '] .name-organization').html(cardDisplayHtml);
    },
    cardName(card) {
      let name = [];
      if (card.board) { name.push(card.board.name); }
      if (card.board_column) { name.push(card.board_column.name); }
      return name.join(' - ');
    },
    changeCard(card) {
      this.browseCards = false;
      this.card = card;
      return false;
    },
    addNewCard() {
      let url = '/api/v2/card/';
      this.$http.post(url,
        { card: {
          mainContactId: this.contact.id,
          contactIds: [this.contact.id],
          companyId: this.company.id,
          userId: Vue.currentUser.userId,
          name: '',
          boardId: this.newBoard.id,
          boardColumnId: this.newBoard.board_columns[0].id
        } });
      this.newBoard = null;
      this.showAddCard = false;
    },

    refreshContact(payload) {
      if (payload.contact) {
        this.contact = payload.contact;
      }

      if (payload.boards) {
        this.boards = payload.boards;
      }

      if (payload.cards) {
        this.cards = payload.cards;
        if (this.card_id) {
          let opp = payload.cards.find((item) => {
            return item.id === this.card_id;
          });
          if (opp) { this.changeCard(opp); }
        } else if (this.cards.length === 1) {
          this.changeCard(this.cards[0]);
        }
      }

      if (payload.company) {
        this.company = payload.company;
      }
      if (payload.company_users) {
        this.companyUsers = payload.company_users;
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

    },

    loadContact() {
      if (this.contact_id) {
        this.$http.get('/api/v2/contact/' + this.contact_id).then(resp => {
          this.refreshContact(resp.data);
        });
      }
    },

    initConn(reset) {
      this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
      this.socket.connect();
      this.channel = this.socket.channel('contacts:' + this.contact_id, {});

      this.channel.join()
                .receive('ok', resp => {  })
                .receive('error', resp => { console.log('Unable to join', resp); });

      if (reset) {
        this.cards = [];
        this.card = null;
        this.company = null;
        this.tags = [];
        this.organization = null;
        this.browseCards = true;
      }

      this.channel.on('update', payload => {
        this.refreshContact(payload);
      });

      this.channel.on('card:created', payload => {
        if (payload.card) {
          this.cards.push(payload.card);
          this.card || (this.card = payload.card);
        }
      });

      this.loadContact();
    }
  },
  mounted(){
    this.timeZone = Vue.currentUser.timeZone;
    this.userImage = Vue.currentUser.userImage;
    if (this.contact_id) { this.initConn(); }
  }

};
</script>
