<template>
  <div class="card-show">
    <div class="row">
      <div class="col-lg-9 card-info">
        <div class="card-title">
          <i class="fa fa-rocket"></i>
          <div class="card-title-input-block">
            <inline-text-edit v-model="card.name" v-on:input="updateCard" placeholder="Card Name"></inline-text-edit>
          </div>
        </div>

        <div class="managers" v-if="companyUsers.length > 0">
          Managed by:
          <select v-model.number="card.userId"  v-on:change="updateCard">
            <option v-for="user in companyUsers" :value.number="user.id">{{user.userName}}</option>
          </select>

        </div>
        <div class="mt-1 mb-1" :class="{ 'is-due-past': !isDueFuture, 'is-due-future': isDueFuture }" v-show="card.dueDate || showDueDatePicker" >
          Due Date:
          <el-date-picker
            class="card-due-date"
            v-on:change="updateCard"
            v-model="card.dueDate"
            type="datetime"
            size="mini"
            format="yyyy-MM-dd HH:mm"
            :editable="false"
            :min_date="new Date()"
            :clearable="true"
            ref="dueDatePicker"
            >
          </el-date-picker>
        </div>

        <div class="card-description">
          <markdown-text-edit v-model="card.description" v-on:input="updateCard" placeholder="Write a description" ></markdown-text-edit>
        </div>

        <div class="card-contacts-container" v-if="contacts.length > 0">
          <div class="title">
            <i class="fa fa-user"></i> Contacts
          </div>
          
          <div class="card-contacts">
            <div class="card-contacts-list">
              <span v-for="(contact, index) in contacts" :class="contactClass(index)">
                <a href='#' v-on:click="activeContactIndex=index">{{ contact.firstName }} {{ contact.lastName }}</a>
                <a class="remove" @click="removeContact(contact.id)">×</a>
              </span>
            </div>

            <div class="active-contact-info" v-if="activeContact()">
              <div class="row contact-attributes">
                <div class="col-lg-4">
                  Name
                  <br />
                  <span class="attribute-value">
                    <name-input-modal :first-name="activeContact().firstName" :last-name="activeContact().lastName" v-on:input="contactNameInput"/>
                  </span>
                </div>

                <div class="col-lg-4">
                  Title
                  <br />
                  <span class="attribute-value">
                    <input-modal v-model="activeContact().jobTitle" v-on:input="updateContact"  placeholder="Click to add" label="Title" />
                  </span>
                </div>

                <div class="col-lg-4">
                  Phone number
                  <br />
                  <span class="attribute-value">
                    <input-modal v-model="activeContact().phone" v-on:input="updateContact"  placeholder="Click to add" label="Phone" />
                  </span>
                </div>

                <div class="col-lg-4">
                  Email
                  <br />
                  <span class="attribute-value">
                    <input-modal v-model="activeContact().email" v-on:input="updateContact"  placeholder="Click to add" label="Email" />
                  </span>
                </div>
              </div>

              <div class="contact-description">
                <markdown-text-edit v-model="activeContact().description" v-on:input="updateContact" placeholder="Write a description" ></markdown-text-edit>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-lg-3 card-actions">
        <button type="button" class="btn btn-default btn-block" @click="addTask">ADD TASK</button>
        <button type="button" class="btn btn-default btn-block" @click="openContactModal = true">ADD CONTACT</button>
        <button type="button" class="btn btn-default btn-block " v-on:click="openDueDatePicker">DUE DATE</button>
        <div class="upload-btn btn btn-default btn-block" style="height: 34px;font-weight:normal;">
          <file-upload
            title="UPLOAD FILE"
            name="attachment"
            :post-action="'/api/v2/card/' + card.id + '/attachments'"
            :headers="uploadHeaders"
            :events="uploadEvents"
            ref="attachment">
          </file-upload>
        </div>
        <button type="button" v-show="card.status === 0" class="btn btn-default btn-block" v-on:click="archiveCard">ARCHIVE</button>
        <button type="button" v-show="card.status === 1" class="btn btn-default btn-block" v-on:click="unarchiveCard">UNARCHIVE</button>
      </div>
    </div>

    <div class="row" v-if="attachments.length > 0">
      <div class="col-lg-12">
        <div class="attachments">
          <h3 style="color:rgb(99,99,99);font-weight:bold;">
            <i class="fa fa-fw fa-paperclip"></i>Attachments
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
      </div>
    </div>

    <div class="row">
      <div class="col-lg-12">
        <to-do
          :activities="activities"
          :companyUsers="companyUsers"
          :card="card"
          :company="company"
          :timeZone="time_zone"
          v-on:taskAddOrUpdate="taskAddOrUpdate"
          v-on:taskDelete="taskDelete"
        >
          <comment_form slot="comment-form"
            :card="card"
            :userImage="userImage()"
            v-on:eventAddOrUpdate="eventAddOrUpdate"
           />
          <timeline_events
            slot="timeline-events"
            :events="events"
            v-on:eventDelete="eventDelete"
            />
        </to-do>
      </div>
    </div>

    <modal large :show.sync="openContactModal">
      <div slot="modal-header" class="modal-header">
       <button type="button" class="close" @click="openContactModal=false"><span>&times;</span></button>
       <h4 class="modal-title">Add contact</h4>
      </div>
        <div slot="modal-body" class="modal-body">
          <add-contact @select-contact="selectContact" />
        </div>

        <div slot="modal-footer" class="modal-footer">
         <button type="button" class="btn btn-success" v-on:click="addContact">Add Contact</button>
        </div>
    </modal>
  </div>
</template>

<script>
  import {Socket, Presence} from 'phoenix';
  import InlineEdit from '../inline-common-edit.vue';
  import InlineTextEdit from '../inline-textedit.vue';
  import MarkdownTextEdit from '../markdown-textedit.vue';
  import ToDo from './to-do-edit.vue';
  import CommentForm from './comment-form.vue';
  import TimelineEvents from './timeline-events.vue';
  import inputModal from '../shared/input-modal.vue';
  import nameInputModal from '../shared/name-input-modal.vue';
  import AddContact from './add-contact.vue';

  export default {
    props: ['cardId'],
    data() {
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
        socket: null,
        attachment: {},
        attachments: [],
        card: {},
        contacts: [],
        contactIds: [],
        activeContactIndex: null,
        events: [],
        activities: [],
        company: null,
        companyUsers: [],
        openContactModal: false,
        addContactData: {},
        showDueDatePicker: false
      };
    },
    watch: {
      cardId() {
        this.initChannel();
      }
    },
    computed: {
      isDueFuture(){
        return this.card.dueDate > new Date();
      },
      uploadHeaders(){
        return { Authorization: 'Bearer ' + Vue.currentUser.token   };
      }
    },
    components: {
      'inline-edit': InlineEdit,
      'inline-text-edit': InlineTextEdit,
      'markdown-text-edit': MarkdownTextEdit,
      'to-do': ToDo,
      'comment_form': CommentForm,
      'timeline_events': TimelineEvents,
      'modal': VueStrap.modal,
      'file-upload': FileUpload,
      'el-date-picker': ElementUi.DatePicker,
      'name-input-modal': nameInputModal,
      'input-modal': inputModal,
      'add-contact': AddContact
    },
    methods: {
      activeContact() {
        return this.contacts[this.activeContactIndex];
      },
      userImage() {
        return Vue.currentUser.userImage;
      },
      contactClass(index) {
        let className = 'contact';
        if(this.activeContactIndex === index) {
          className += ' active';
        }
        return className;
      },
      contactNameInput: function(data) {
        this.contacts[this.activeContactIndex].firstName = data.firstName;
        this.contacts[this.activeContactIndex].lastName = data.lastName;
        this.updateContact();
      },
      eventAddOrUpdate(event) {
        let itemIndex = this.events.findIndex(function(item){
          return item.id === parseInt(event.id);
        });
        if (itemIndex === -1){
          this.events.unshift(event);
        } else {
          this.events.splice(itemIndex, 1, event);
        }
      },
      eventDelete(eventId) {
        let itemIndex = this.$data.events.findIndex(function(item){
          return item.id === parseInt(eventId);
        });
        if (itemIndex !== -1){ this.$data.events.splice(itemIndex, 1); }
      },
      openDueDatePicker() {
        let vm = this;
        vm.showDueDatePicker = true;
        vm.$refs.dueDatePicker.handleClose = function() {
          vm.showDueDatePicker = false;
          this.pickerVisible = false;
        };
        vm.$refs.dueDatePicker.showPicker();
      },
      addTask() {
        let url = '/api/v2/activity/';
        this.$http.post(url, {
          activity: {
            contactId: this.contacts[this.activeContactIndex].id,
            cardId: this.cardId,
            userId: Vue.currentUser.userId,
            dueDate: new Date().toISOString(),
            companyId: this.company.id,
            title: 'Call',
            currentUserTimeZone: Vue.currentUser.timeZone
          } }).then( resp => { this.taskAddOrUpdate(resp.data.data); });
      },
      selectContact(data) {
        this.addContactData = data;
      },
      addExistingContact(contact) {
        let cardUrl = '/api/v2/card/'+ this.cardId;
        this.contacts.push(contact);
        this.card.contactIds = this.card.contactIds || [];
        this.card.contactIds.push(contact.id);
        this.$http.put(cardUrl,{ card: { contactIds: this.card.contactIds  } }).then(resp2 => {
          this.activeContactIndex = this.contacts.length-1;
          this.openContactModal = false;
        });
      },
      addContact(){
        if(this.addContactData.isExistingContact) {
          this.addExistingContact(this.addContactData.contact);
        } else {
          let url = '/api/v2/contact';
          let contact = this.addContactData.contact;
          if(contact) {
            let data = {
              name: contact.name,
              email: contact.email,
              phone: contact.phone,
              userId: this.card.userId
            };
            if (this.company) {
              data['company_id'] = this.company.id;
            }
            if (this.organization) {
              data['organization_id'] = this.organization.id;
            }

            this.$http.post(url, { contact: data }).then(resp => {
              if(resp.data.errors) {
                alert('Please select a contact name from the list');
              } else {
                this.addExistingContact(resp.data.data);
              }
            });
          } else {
            alert('Please select a contact name from the list');
          }
        }
      },

      taskAddOrUpdate(task) {
        let itemIndex = this.$data.activities.findIndex(function(item){
          return item.id === parseInt(task.id);
        });
        if (itemIndex === -1){
          this.$data.activities.push(task);
        } else {
          this.$data.activities.splice(itemIndex, 1, task);
        }
      },

      taskDelete(taskId) {
        let itemIndex = this.$data.activities.findIndex(function(item){
          return item.id === parseInt(taskId);
        });
        if (itemIndex !== -1){ this.$data.activities.splice(itemIndex, 1); }
      },
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
        let url = '/api/v2/card/'+this.cardId+'/attachments/' + attachId;
        this.$http.delete(url, {  });
      },

      updateCard() {
        let url = '/api/v2/card/' + this.cardId;
        this.$http.put(url, { card: this.card });
      },

      updateContact: function(){
        let url = '/api/v2/contact/' + this.contacts[this.activeContactIndex].id;
        this.$http.put(url, { contact: this.contacts[this.activeContactIndex] } );
      },

      removeContact(contactId) {
        console.log(contactId);
        if(confirm('Are you sure?')) {
          this.card.contactIds = window.Array.from(this.card.contactIds); // This eliminates duplicate contactids
          this.card.contactIds.splice(this.card.contactIds.indexOf(contactId), 1);

          let url = '/api/v2/card/' + this.cardId;
          this.$http.put(url, {card: { contactIds: this.card.contactIds}}).then(resp => {
            if(resp.data.errors && resp.data.errors.contactIds) {
              alert(resp.data.errors.contactIds);
            } else {
              var index = -1;
              for(var i=0; i < this.contacts.length; i++) {
                if(this.contacts[i].id === contactId) {
                  index = i;
                  break;
                }
              }

              if(index !== -1) {
                this.contacts.splice(index, 1);

                if(this.activeContactIndex >= this.contacts.length)
                  this.activeContactIndex = 0;
              }
            }
          }, resp => {
            if(resp.data.errors.contactIds) {
              alert(resp.data.errors.contactIds);
            }
          });
        }
      },

      archiveCard() {
        let url = '/api/v2/card/' + this.cardId;
        this.$http.put(url, { card: { status: '1'} }).then(resp => {
          $('.portlet[data-id=' + this.cardId + ']').hide();
          this.card = resp.data.data;
        });
      },

      unarchiveCard() {
        let url = '/api/v2/card/' + this.cardId;
        this.$http.put(url, { card: { status: '0'} }).then(resp => {
          $('.portlet[data-id=' + this.cardId + ']').show();
          this.card = resp.data.data;
        });
      },

      refreshCard(payload){
        if(payload.company) {
          this.company = payload.company;
        }

        if(payload.companyUsers) {
          this.companyUsers = payload.companyUsers;
        }

        if (payload.activities) {
          this.activities = payload.activities;
        }

        if (payload.board) {
          this.board = payload.board;
          this.boardColumns = payload.board_columns;
        }

        if (payload.events) {
          this.events = payload.events;
        }

        if (payload.card) {
          this.card = payload.card;
        }
        if (payload.cardContacts) {
          this.contacts = payload.cardContacts;
        }

        if (payload.attachments) {
          this.attachments = payload.attachments;
        }
        this.allowUpdate = true;
      },

      subscribe() {
        this.cardChannel.on('card:updated', payload => {
          let _payload = window.toCamel(payload);
          if (_payload.card) {
            this.card = _payload.card;
            this.cardContacts = _payload.cardContacts;
          }
        });

        this.cardChannel.on('card:added_attachment', payload => {
          this.attachments.unshift(payload.attachment);
        });

        this.cardChannel.on('card:deleted_attachment', payload => {
          if (payload.card) {
            let cardIndex = this.attachments.findIndex(function(card){
              return card.id === parseInt(payload.attachment_id);
            });

            this.attachments.splice(cardIndex, 1);
          }
        });

        this.cardChannel.on('activity:created', payload => {
          let _payload = window.toCamel(payload);
          this.taskAddOrUpdate(_payload.activity);
        });

        this.cardChannel.on('activity:deleted', payload => {
          let _payload = window.toCamel(payload);
          this.taskDelete(_payload.activityId);
        });

        this.cardChannel.on('activity:updated', payload => {
          let _payload = window.toCamel(payload);
          this.taskAddOrUpdate(_payload.activity);
        });

        this.cardChannel.on('timeline_event:created', payload => {
          let _payload = window.toCamel(payload);
          if (_payload.event.eventName === 'comment') {
            this.eventAddOrUpdate(_payload.event);
          }
        });

        this.cardChannel.on('timeline_event:updated', payload => {
          let _payload = window.toCamel(payload);
          if (_payload.event.eventName === 'comment') {
            this.eventAddOrUpdate(_payload.event);
          }
        });

        this.cardChannel.on('timeline_event:deleted', payload => {
          let _payload = window.toCamel(payload);
          this.eventDelete(_payload.id);
        });
      },
      leaveChannel() {
        if (this.cardChannel) {
          this.cardChannel.leave();
        }
      },
      initChannel(){
        this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
        this.socket.connect();
        let channelTopic = 'cards:' + this.cardId;
        if (this.cardId) {
          this.$http.get('/api/v2/card/' + this.cardId).then(resp => {
            this.refreshCard(resp.data);
            this.activeContactIndex = 0;
          });
        }
        this.cardChannel = this.socket.channel(channelTopic, {});
        this.subscribe();
        this.cardChannel.join()
              .receive('ok', resp => { })
              .receive('error', resp => {  });
      }
    },
    mounted(){
      this.initChannel();
    }
  };
</script>

<style lang="sass">
  .card-show {
    padding: 20px;
    background-color: #edf0f5;

    .modal-body {
      padding: 10px;
    }

    .fa {
      color:#d8d8d8;
    }

    .file-uploads-title {
      font-weight: normal;
    }

    .card-title {
      color: rgb(99, 99, 99);
      font-weight: bold;
      font-size: 24px;

      .fa {
        position: relative;
        top: 10px;
        float: left;
      }

      .card-title-input-block {
        margin-left: 30px;
      }
    }

    .card-description {
      min-height: 100px;
    }

    .card-contacts-container {
      margin-top: 30px;

      .title {
        color: rgb(99, 99, 99);
        font-weight: bold;
        font-size: 24px;
      }

      /*-----Start Contacts-------*/
      .card-contacts {
        background-color: #ffffff;
        padding: 10px;

        .contact {
          margin-right:7px;
          border-radius: 5px;
          display:inline-block;
          padding: 3px;

          &.active {
            border: 1px solid lightgray;
          }
        }
        .contact a  {
          font-weight:bold;
          display:inline-block;
          border-radius:5px;
          color:grey;
          text-decoration:none;
        }
        .contact a.remove {
          cursor: pointer;
          text-decoration: none;
          line-height: 1;
        }
        /*-----End Contacts-------*/

        .active-contact-info {
          margin-top: 10px;

          .attribute-value {
             margin-right:7px;
             border-radius: 5px;
             display:inline-block;
             padding: 0 3px;
             background-color: lightgray;
          }

          .contact-attributes {
            margin-bottom: 10px;
          }

          .contact-description {
            min-height: 100px;
          }
        }
      }
    }
  }
</style>
