<template>
  <div class="col-md-12 card-block">
    <div class="post" v-if="item">
    <div class="pull-right">
      <button type="button" class="btn btn-primary pull-right browse" v-on:click="browse">See all Cards</button>
      <br />
       <div class="upload-btn btn btn-default archive" style="margin-top: 10px; height: 34px;width: 130px;font-weight:normal;">
        <file-upload
          title="UPLOAD FILE"
          name="attachment"
          :post-action="'/api/v2/card/' + card.id + '/attachments'"
          :headers="uploadHeaders"
          :events="uploadEvents"
          ref="attachment">
        </file-upload>
      </div>
      <br />
      <button type="button" class="btn btn-default archive " v-on:click="archiveCard">ARCHIVE</button>
      <br />
      <div class="text-center" style="margin-top:10px;color:grey;">
        <a class="show-more" v-show="!showMoreOptions" @click="showMoreOptions=true" style="text-decoration:none;">+More options</a>
      </div>
      <div v-show="showMoreOptions">
        <delete-contact :contact="contact"></delete-contact>
      </div>
    </div>
      <div style="" id="change_status">
        <span style="font-size:24px;"> <i class="fa fa-rocket" style="color:#d8d8d8;"></i>
          <span data-placeholder="Project Name" style="color:rgb(99,99,99);font-weight:bold;">
            In {{board.name}}
            -
          <select v-model="item.board_column_id" v-on:change="updateCard">
             <option v-for="board_column in boardColumns" :value.number="board_column.id">{{board_column.name}}</option>
          </select>
            <div v-if="item.name">
            <inline-edit v-model="item.name" v-on:input="updateCard" placeholder="Card Name" style="width:500px;margin-left:25px;color:grey;"></inline-edit>
            </div>
          </span>
        </span>
        <br />
        <br />
        Contacts Involved:
        <a v-for="o_contact in cardContacts" :href="'/contact/'+o_contact.id" class="o_contact">{{o_contact.name}}</a>
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
        <div class="managers">
          Managed by:
          <select v-model.number="item.user_id"  v-on:change="updateCard">
            <option v-for="user in company_users" :value.number="user.id">{{user.user_name}}</option>
          </select>

        </div>

            <div class="mt-1 mb-1">
              Description
              <br />
              <div class="mt-1" data-placeholder="Write a description...">
               <markdown-text-edit v-model="item.description" v-on:input="updateCard" placeholder="Write a description" ></markdown-text-edit>
              </div>
              <br />
            </div>
      </div>
      <div class="attachments">

         <h3 style="color:rgb(99,99,99);font-weight:bold;"  v-if="attachments.length > 0">
           <i class="fa fa-fw fa-paperclip" style="color:#d8d8d8;"></i>Attachments
         </h3>

         <div v-if="attachments.length > 0">
           <div v-for="attach in attachments" :class="['attach-item', attach.ext_file]">
             <div :class="['thumb', fileTypeClass(attach)]" >
               <img :src="attach.thumb_url" v-if="attach.image" />
             </div>
             <div class="info">
             <div>{{attach.file_name}}</div>
             <div>Added {{attach.inserted_at | moment('MMM DD [at] h:m A')}}</div>
             <div class="attach-action">
              <a :href="attach.attachment_url" target="_blank">
               <i class="fa fa-download" aria-hidden="true"></i>
               Download</a>
              <button class="btn btn-link" v-on:click.stop="deleteAttachment(attach.id)">
              <i class="fa fa-times" aria-hidden="true"></i>
               Delete</button>
             </div>
             </div>
           </div>
         </div>
        </div>
      <to-do
        :activities="activities"
        :companyUsers="company_users"
        :contact="contact"
        :card="card"
        :company="company"
        :timeZone="time_zone"
      >

        <comment_form slot="comment-form" :contact="contact" :card="card" :user_image="user_image" />
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
  import MarkdownTextEdit from '../markdown-textedit.vue';
  import DeleteContact from './delete.vue';

  export default {
    props: [
      'socket',
      'contact', 'time_zone', 'current_user_id',
      'card', 'company',
      'cards',
      'company_users',
      'organization',
      'user_image'
    ],
    data(){
      return {
        uploadEvents: {
          add(file, component) {
            component.active = true;
          },
          progress(file, component) {
            let msg = 'Uploading ' + Math.ceil(file.progress) + '%';
            this.$notification.$emit('alert', {'msg': msg});
          },
          after(file, component) {
            this.$notification.$emit('alert', {'msg': 'Finished!'});
          },
          before(file, component) {
            this.$notification.$emit('alert', {'msg': 'Start upload'});
          }
        },
        attachment: {},
        attachments: [],
        openContactModal: false,
        allowUpdate: true,
        item: this.card,
        items: this.cards,
        contacts: this.cardContacts,
        boardColumns: [],
        board: {},
        cardChannel: null,
        activities: [],
        events: [],
        cardContacts: [],
        showMoreOptions: false

      };
    },
    computed: {

      uploadHeaders(){
        return { Authorization: 'Bearer ' + Vue.currentUser.token   };
      }
    },
    methods: {
      fileTypeClass(attach) {
        const klasses = {
          '.pdf': 'fa fa-file-pdf-o'
        };

        let cssClass = '';
        if (!attach.image) {
          cssClass = 'file ' + (klasses[attach.ext_file] || 'fa fa-file-o');
        }
        return cssClass;
      },
      deleteAttachment(attachId) {
        let url = '/api/v2/card/'+this.item.id+'/attachments/' + attachId;
        this.$http.delete(url, {  });
      },
      browse(){
        this.leaveChannel();
        this.$emit('browse');
      },
      addContact(){
        let url = '/api/v2/contact';
        let data = {
          name: this.NewContactName,
          userId: this.card.user_id
        };
        if (this.company) {
          data['company_id'] = this.company.id;
        }
        if (this.organization) {
          data['organization_id'] = this.organization.id;
        }
        this.$http.post(url, { contact: data }).then(resp => {
          let urlOpp = '/api/v2/card/'+ this.card.id;
          let contactIds = [];
          this.cardContacts.forEach(function(item) {
            contactIds.push(item.id);
          });
          contactIds.push(resp.data.data.id);
          this.$http.put(urlOpp,{ card: { contactIds: contactIds } });
        });

        this.NewContactName = '';
        this.openContactModal = false;
      },

      archiveCard() {
        let url = '/api/v2/card/' + this.item.id;
        this.$http.put(url, { card: { status: '1'} });
      },

      updateCard(){
        if (this.allowUpdate) {
          let url = '/api/v2/card/' + this.item.id;
          this.$http.put(url, { card: this.item });
        }
      },

      refreshCard(payload){
        if (payload.activities) {
          this.$data.activities = payload.activities;
        }
        if (payload.board) {
          this.$data.board = payload.board;
          this.$data.boardColumns = payload.board_columns;
        }

        if (payload.events) {
          this.$data.events = payload.events;
        }

        if (payload.card) {
          this.$data.item = payload.card;
        }
        if (payload.card_contacts) {
          this.$data.cardContacts = payload.card_contacts;
        }

        if (payload.attachments) {
          this.$data.attachments = payload.attachments;
        }
        this.allowUpdate = true;
      },

      subscribe() {

        this.cardChannel.on('card:closed', payload => {
          if (payload.card) {
            let itemIndex = this.cards.findIndex(function(item){
              return item.id === parseInt(payload.card.id);
            });
            this.$data.items.splice(itemIndex,1);

            if (this.$data.items.length === 0) {
              this.clearCard();
            } else if (this.$data.item.id === parseInt(payload.card.id)) {
              this.setCard(this.$data.items[0]);
            }
            this.$emit('browse');
          }
        });
        this.cardChannel.on('card:updated', payload => {
          if (payload.card) {
            this.$data.item = payload.card;
            this.$data.cardContacts = payload.card_contacts;

            let itemIndex = this.cards.findIndex(function(item){
              return item.id === parseInt(payload.card.id);
            });

            this.$data.items.splice(itemIndex, 1, payload.card);
          }
          if (payload.board) {
            this.$data.board = payload.board;
            this.$data.boardColumns = payload.board_columns;
          }
        });

        this.cardChannel.on('card:added_attachment', payload => {
          if (payload.card) {
            this.$data.attachments.unshift(payload.attachment);
          }
        });

        this.cardChannel.on('card:deleted_attachment', payload => {
          if (payload.card) {

            let itemIndex = this.attachments.findIndex(function(item){
              return item.id === parseInt(payload.attachment_id);
            });

            this.$data.attachments.splice(itemIndex, 1);
          }
        });


        this.cardChannel.on('activity:created', payload => {
          this.$data.activities.push(payload.activity);
        });

        this.cardChannel.on('activity:deleted', payload => {
          let itemIndex = this.$data.activities.findIndex(function(item){
            return item.id === parseInt(payload.activity_id);
          });
          this.$data.activities.splice(itemIndex, 1);
        });

        this.cardChannel.on('activity:updated', payload => {
          let itemIndex = this.$data.activities.findIndex(function(item){
            return item.id === parseInt(payload.activity.id);
          });
          this.$data.activities.splice(itemIndex, 1, payload.activity);
        });

        this.cardChannel.on('timeline_event:created', payload => {
          this.$data.events.unshift(payload.event);
        });

        this.cardChannel.on('timeline_event:updated', payload => {

          let itemIndex = this.$data.events.findIndex(function(item){
            return item.id === parseInt(payload.event.id);
          });
          this.$data.events.splice(itemIndex, 1, payload.event);
        });

        this.cardChannel.on('timeline_event:deleted', payload => {
          let itemIndex = this.$data.events.findIndex(function(item){
            return item.id === parseInt(payload.id);
          });
          this.$data.events.splice(itemIndex, 1);
        });
      },
      leaveChannel() {
        if (this.$data.cardChannel) {
          this.$data.cardChannel.leave();
        }
      },
      initChannel(){
        let channelTopic = 'cards:' + this.card.id;
        if (this.card.id) {
          this.$http.get('/api/v2/card/' + this.card.id).then(resp => {
            this.refreshCard(resp.data);
          });
        }
        this.cardChannel = this.socket.channels.find(function(item){
          return channelTopic === item.topic;
        });

        if (this.cardChannel) {
          this.subscribe();
        } else {
          this.cardChannel = this.socket.channel(channelTopic, {});
          this.subscribe();
          this.cardChannel.join()
                .receive('ok', resp => { })
                .receive('error', resp => {  });
        }
      },

      clearCard() {
        this.allowUpdate = false;
        this.$data.item = null;
        this.leaveChannel();
      },
      setCard(opp) {
        this.allowUpdate = false;
        this.$data.item = opp;
        this.initChannel();
      }
    },
    watch: {
      card() {
        this.allowUpdate = false;
        this.$data.item = this.card;

        if (this.card){
          this.initChannel();
        } else { this.leaveChannel(); }
      }
    },
    components: {
      'inline-edit': InlineEdit,
      'to-do': ToDo,
      'comment_form': CommentForm,
      'timeline_events': TimelineEvents,
      'markdown-text-edit': MarkdownTextEdit,
      'v-select': vSelect.VueSelect,
      'modal': VueStrap.modal,
      'file-upload': FileUpload,
      'delete-contact': DeleteContact
    },


    mounted() {
      this.attachment = this.$refs.attachment.$data;
      this.initChannel();
    }

  };
</script>
<style lang="sass">
  .attachments {
  margin-bottom: 20px;
  .attach-item {
  position: relative;
  border-bottom: 0.1em solid #e4e4e4;


  .thumb {
  height: 75px;
  width: 75px;
  img {
  max-height: 75px;
  max-width: 75px;
  }
  &.file {
  font-size: 55px;
  &:before {
  position: absolute;
  top: 8px;
  left: 8px;
  }
  }
  }
  .info {
  position:absolute;
  left: 105px;
  top: 0px;
  }

  }
  }

  .show-more, .hide-more,
  .show-more:hover, .hide-more:hover {
    color: #333;
    cursor: pointer;
    text-decoration: underline;
    margin-top: 10px;
    display: block;
  }
</style>
