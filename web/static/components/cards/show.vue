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
              <span v-for="contact in contacts" :class="contactClass(contact)">
                <a href='#' v-on:click="changeContactDisplay($event, contact.id)">{{ contact.firstName }} {{ contact.lastName }}</a>
                <a class="remove" @click="removeContact(contact.id)">×</a>
              </span>
            </div>

            <div class="active-contact-info" v-if="activeContact">
              <div class="row contact-attributes">
                <div class="col-lg-4">
                  Name
                  <br />
                  <span class="attribute-value">
                    <name-input-modal :first-name="activeContact.firstName" :last-name="activeContact.lastName" v-on:input="contactNameInput"/>
                  </span>
                </div>

                <div class="col-lg-4">
                  Title
                  <br />
                  <span class="attribute-value">
                    <input-modal v-model="activeContact.jobTitle" v-on:input="updateContact"  placeholder="Click to add" label="Title" />
                  </span>
                </div>

                <div class="col-lg-4">
                  Phone number
                  <br />
                  <span class="attribute-value">
                    <input-modal v-model="activeContact.phone" v-on:input="updateContact"  placeholder="Click to add" label="Phone" />
                  </span>
                </div>

                <div class="col-lg-4">
                  Email
                  <br />
                  <span class="attribute-value">
                    <input-modal v-model="activeContact.email" v-on:input="updateContact"  placeholder="Click to add" label="Email" />
                  </span>
                </div>
              </div>

              <div class="contact-description">
                <markdown-text-edit v-model="activeContact.description" v-on:input="updateContact" placeholder="Write a description" ></markdown-text-edit>
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
        attachment: {},
        attachments: [],
        card: {},
        contacts: [],
        contactIds: [],
        activeContact: null,
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
        this.initialize();
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
      userImage() {
        return Vue.currentUser.userImage;
      },
      contactClass(contact) {
        let className = 'contact';
        if(this.activeContact && this.activeContact.id === contact.id) {
          className += ' active';
        }
        return className;
      },
      contactNameInput: function(data) {
        this.$set(this.activeContact, 'firstName', data.firstName);
        this.$set(this.activeContact, 'lastName', data.lastName);
        this.updateContact();
      },
      eventAddOrUpdate(event) {
        let itemIndex = this.$data.events.findIndex(function(item){
          return item.id === parseInt(event.id);
        });
        if (itemIndex === -1){
          this.$data.events.unshift(event);
        } else {
          this.$data.events.splice(itemIndex, 1, event);
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
            contactId: this.activeContact.id,
            cardId: this.card.id,
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
      addContact(){
        let cardUrl = '/api/v2/card/'+ this.card.id;
        if(this.addContactData.isExistingContact) {
          this.contacts.push(this.addContactData.contact);
          this.card.contactIds = this.card.contactIds || [];
          this.card.contactIds.push(this.addContactData.contact.id);
          this.$http.put(cardUrl,{ card: { contactIds: this.card.contactIds  } }).then(resp2 => {
            this.changeContactDisplay(null, this.addContactData.contact.id);
          });
        } else {
          let url = '/api/v2/contact';
          let data = {
            name: this.addContactData.contact.name,
            email: this.addContactData.contact.email,
            phone: this.addContactData.contact.phone,
            userId: this.card.userId
          };
          if (this.company) {
            data['company_id'] = this.company.id;
          }
          if (this.organization) {
            data['organization_id'] = this.organization.id;
          }
          this.$http.post(url, { contact: data }).then(resp => {
            this.contacts.push(resp.data.data);
            this.card.contactIds = this.card.contact_ids || [];
            this.card.contactIds.push(resp.data.data.id);
            this.$http.put(cardUrl,{ card: { contactIds: this.card.contactIds  } }).then(resp2 => {
              this.changeContactDisplay(null, resp.data.data.id);
            });
          });
        }

        this.newContactName = '';
        this.openContactModal = false;
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

      updateCard() {
        let url = '/api/v2/card/' + this.card.id;
        this.$http.put(url, { card: this.card });
      },

      updateContact: function(){
        let url = '/api/v2/contact/' + this.activeContact.id;
        this.$http.put(url, { contact: this.activeContact } );
      },

      changeContactDisplay(event, contactId) {
        for(var i=0; i<this.contacts.length; i++) {
          if(this.contacts[i].id === contactId) {
            this.activeContact = this.contacts[i];
            this.loadContactInfo();
            break;
          }
        }
      },

      removeContact(contactId) {
        if(confirm('Are you sure?')) {
          this.card.contactIds.splice(this.card.contactIds.indexOf(contactId), 1);

          let url = '/api/v2/card/' + this.card.id;
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
              }

              if(this.activeContact.id === contactId && this.contacts.length>0)
                this.changeContactDisplay(null, this.contacts[0].id);
            }
          }, resp => {
            if(resp.data.errors.contactIds) {
              alert(resp.data.errors.contactIds);
            }
          });
        }
      },

      archiveCard() {
        let url = '/api/v2/card/' + this.card.id;
        this.$http.put(url, { card: { status: '1'} }).then(resp => {
          $('.portlet[data-id=' + this.card.id + ']').hide();
          this.$glmodal.$emit('close');
          this.card = resp.data.data;
        });
      },

      unarchiveCard() {
        let url = '/api/v2/card/' + this.card.id;
        this.$http.put(url, { card: { status: '0'} }).then(resp => {
          this.card = resp.data.data;
        });
      },

      loadContactInfo() {
        if (this.activeContact) {
          this.$http.get('/api/v2/contact/' + this.activeContact.id).then(resp => {
            this.activeContact.firstName = resp.data.contact.firstName;
            this.activeContact.lastName = resp.data.contact.lastName;
          });
        }
      },

      initialize() {
        this.$http.get('/api/v2/card/' + this.cardId).then(resp => {
          this.card = resp.data.card;
          this.contacts = resp.data.cardContacts;
          this.contactIds = resp.data.card.contactIds;
          this.activeContact = this.contacts[0];
          this.activities = resp.data.activities;
          this.events = resp.data.events;
          this.company = resp.data.company;
          this.companyUsers = resp.data.companyUsers;

          this.loadContactInfo();
        });
      }
    },
    mounted(){
      this.initialize();
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
