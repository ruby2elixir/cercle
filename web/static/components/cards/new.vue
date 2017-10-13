<template>
  <div class="new-card-form" v-on:keydown.enter="saveData">
    <div class="form-group">
      <input type="text" title="Name of the Card" v-model="name" placeholder="Name of the Card" class="form-control" ref="name" />
      <span class='error' v-show="errors.name" v-for="msg in errors.name">{{msg}}</span>
    </div>

    <div class="form-group" v-show="defaultBoardId==null">
      <label>Board</label>
    </div>
    <div class="form-group">
      <select v-model="boardId" class="form-control" v-on:change="loadColumns">
        <option v-for="board in boards" :value="board.id">{{ board.name }}</option>
      </select>
    </div>
    <div class="form-group">
      <select v-model="columnId" class="form-control">
        <option v-for="col in columns" :value="col.id">{{ col.name }}</option>
      </select>
    </div>
    <i>Include a contact into the card (optional)</i>
    <Br />
    <Br />
    <add-contact @select-contact="selectContact" />


    <div class="form-group">
      <button class="btn btn-success" v-on:click="saveData">Save</button>
      <a class="btn btn-link" @click="cancel">Cancel</a>
    </div>
  </div>
</template>

<script>
  import AddContact from './add-contact.vue';
  export default {
    props: ['userId', 'companyId', 'boards', 'defaultBoardId'],
    data: function() {
      return {
        name: null,
        description: null,
        columnId: null,
        columns: [],
        boardId: this.defaultBoardId,
        existingContactId: false,
        searchedContacts: [],
        contact: {
          name: '',
          email: '',
          phone: ''
        },
        errors: {}
      };
    },
    components: {
      'v-select': vSelect.VueSelect,
      'add-contact': AddContact
    },
    methods: {
      reset: function() {
        this.name = null;
        this.description = null;
        this.columnId = null;
        this.columns = [];
        this.boardId = this.defaultBoardId;
        this.existingContactId = false;
        this.searchedContacts = [];
        this.contact = {
          name: '',
          email: '',
          phone: ''
        };
        this.errors = {};
      },
      loadColumns: function() {
        let board = this.boards.filter( (b)  => {
          return b.id === parseInt(this.boardId);
        })[0];

        if (board)
          this.columns = board.board_columns || board.boardColumns;
        if (this.columns.length)
          this.columnId = this.columns[0].id;
      },

      saveCard: function(contactIds = []){
        let url = '/api/v2/company/'+ Vue.currentUser.companyId +'/card/';
        this.$http.post(url,{
          card: {
            companyId: this.companyId,
            contactIds: contactIds,
            boardId: this.boardId,
            boardColumnId: this.columnId,
            name: this.name,
            description: this.description
          }
        }).then(
          resp => { this.$emit('close'); this.reset(); },
          resp => { this.errors = resp.body.errors; }
        );
      },

      saveData: function() {
        if(this.existingContactId) {
          this.saveCard([this.existingContactId]);
        } else if(this.contact.name) {
          let url = '/api/v2/company/'+ Vue.currentUser.companyId +'/contact';
          this.$http.post(url,{
            contact: {
              userId: this.userId,
              companyId: this.companyId,
              name: this.contact.name,
              email: this.contact.email,
              phone: this.contact.phone
            }
          }).then( resp => {
            this.saveCard([resp.data.data.id]);
          });
        } else {
          this.saveCard();
        }
      },

      cancel: function() {
        this.$emit('close');
        this.reset();
      },

      selectContact(data) {
        if(data.isExistingContact) {
          this.existingContactId = data.contact.id;
        } else {
          this.existingContactId = null;
        }
        this.contact.name = data.contact.name;
        this.contact.email = data.contact.email;
        this.contact.phone = data.contact.phone;
      }
    },
    mounted: function() {
      this.loadColumns();
      this.$on('onOpen', function(options){
        this.$refs.name.focus();
      });
      this.$on('onClose', function(options){
        this.reset();
      });
    }
  };
</script>

<style lang="sass">
  .new-card-form {
    padding: 15px;
    .error {
      color: red;
      font-size: 80%;
      padding-left: 2px;
      }
    .card-description-rendering {
      min-height: 100px;
    }
  }
</style>
