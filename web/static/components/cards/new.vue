<template>
  <div class="new-card-form">
    <div class="form-group">
      <input type="text" v-model="name" placeholder="Name" class="form-control" />
    </div>
    <div class="form-group">
      <textarea class="form-control" v-model="description" placeholder="Write a description"></textarea>
    </div>


    <div class="form-group">
      <v-select v-model="contact.name"
                :debounce="250"
                :on-change="selectContact"
                :on-search="searchContacts"
                :options="searchedContacts"
                :taggable="true"
                placeholder="Full Name"
                label="name"><span slot="no-options"></span></v-select>
    </div>
    <div class="form-group">
      <input type="email" v-model="contact.email" placeholder="Email" class="form-control" :disabled="existingContactId!=null" />
    </div>
    <div class="form-group">
      <input type="phone" v-model="contact.phone" placeholder="Phone" class="form-control" :disabled="existingContactId!=null" />
    </div>


    <div class="form-group" v-show="defaultBoardId==null">
      <label>
        Board
      </label>
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
    <div class="form-group">
      <button class="btn btn-success" v-on:click="saveData">Save</button>
      <a class="btn btn-link" @click="cancel">Cancel</a>
    </div>
  </div>
</template>

<script>
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
        }
      };
    },
    components: {
      'v-select': vSelect.VueSelect
    },
    methods: {
      loadColumns: function() {
        let board = this.boards.filter( (b)  => {
          return b.id === parseInt(this.boardId);
        })[0];

        if (board)
          this.columns = board.board_columns;
        if (this.columns.length)
          this.columnId = this.columns[0].id;
      },

      saveCard: function(contactIds = []){
        let url = '/api/v2/card/';
        this.$http.post(url,{
          card: {
            userId: this.userId,
            companyId: this.companyId,
            contactIds: contactIds,
            boardId: this.boardId,
            boardColumnId: this.columnId,
            name: this.name,
            description: this.description
          }
        }).then(resp => {
          window.location.href = "/board/" + resp.data.data.board.id;
        });
      },

      saveData: function() {
        if(this.existingContactId) {
          this.saveCard([this.existingContactId]);
        } else if(this.contact.name) {
          let url = '/api/v2/contact';
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
      },

      selectContact(con) {
        if(typeof con!=='string') {
          this.existingContactId = con.id;
          this.contact.email = con.email;
          this.contact.phone = con.phone;
        } else {
          this.existingContactId = null;
          this.contact.name = con;
          this.contact.email = null;
          this.contact.phone = null;
        }
      },

      searchContacts(search, loading) {
        loading(true);
        this.$http.get('/api/v2/contact', { params: { q: search }}).then(resp => {
          this.searchedContacts = resp.data.data;
          loading(false);
        });
      }
    },
    mounted: function() {
      this.loadColumns();
    }
  };
</script>

<style lang="sass">
  .new-card-form {
    padding: 15px;

    .card-description-rendering {
      min-height: 100px;
    }
  }
</style>
