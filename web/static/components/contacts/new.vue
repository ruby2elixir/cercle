<template>
  <div class="new-contact" style="padding: 10px;">
    <div class="form-group">
      <v-select v-model="name"
                :debounce="250"
                :on-change="selectContact"
                :on-search="searchContacts"
                :options="contacts"
                :taggable="true"
                placeholder="Name..."
                label="name"></v-select>
    </div>
    <div class="form-group">
      <input type="email" v-model="email" placeholder="Email" class="form-control" :disabled="existingContactId!=null" />
    </div>
    <div class="form-group">
      <input type="phone" v-model="phone" placeholder="phone" class="form-control" :disabled="existingContactId!=null" />
    </div>
    <div class="form-group" v-show="defaultBoardId==null">
      <label>
        <input type="checkbox" v-model="addToBoard" value="true" :disabled="existingContactId!=null" />
        Add to board
      </label>
    </div>
    <div class="form-group" v-show="defaultBoardId==null">
      <select v-model="boardId" class="form-control" :disabled="addToBoard!=true" v-on:change="loadColumns">
        <option v-for="board in boards" :value="board.id">{{ board.name }}</option>
      </select>
    </div>
    <div class="form-group">
      <select v-model="columnId" class="form-control" :disabled="addToBoard!=true">
        <option v-for="col in columns" :value="col.id">{{ col.name }}</option>
      </select>
    </div>
    <div class="form-group">
      <button class="btn btn-success" v-on:click="saveContact">Save</button>
      <a @click="cancel">Cancel</a>
    </div>
  </div>
</template>

<script>
export default {
  props: ['userId', 'companyId', 'boards', 'defaultBoardId'],
  data: function() {
    return {
      name: null,
      email: null,
      phone: null,
      columnId: null,
      columns: [],
      boardId: this.defaultBoardId,
      addToBoard: true,
      existingContactId: null,
      contacts: []
    };
  },
  components: {
    'v-select': vSelect.VueSelect
  },
  methods: {
    loadColumns: function() {
      this.columns = [];
      for(var i=0; i<this.boards.length; i++) {
        if(this.boardId === this.boards[i].id) {
          this.columns = this.boards[i].board_columns;
          break;
        }
      }
      if(this.columns.length)
        this.columnId = this.columns[0].id;
    },

    addContactToBoard: function(userId, companyId, contactId, boardId, columnId) {
      $.ajax( '/api/v2/card/' , {
        method: 'POST',
        headers: {'Authorization': 'Bearer '+Vue.currentUser.token},
        data: {
          'card[contact_ids]': [contactId],
          'card[user_id]': userId,
          'card[company_id]': companyId,
          'card[board_id]': boardId,
          'card[board_column_id]': columnId,
          'card[name]': ''
        },
        complete: function(xhr, status){
          window.location.href='/board/'+boardId;
        }
      });
    },

    saveContact: function(){
      var _vue = this;
      var userId = this.userId;
      var companyId = this.companyId;
      var boardId = this.boardId;
      var columnId = this.columnId;

      if(this.existingContactId) {
        this.addContactToBoard(userId, companyId, this.existingContactId, boardId, columnId);
      } else if(this.name){
        var addToBoard = this.addToBoard;
        $.ajax('/api/v2/contact', {
          method: 'POST',
          data: {
            'contact[user_id]': userId,
            'contact[company_id]': companyId,
            'contact[name]': this.name,
            'contact[email]': this.email,
            'contact[phone]': this.phone
          },
          headers: {'Authorization': 'Bearer '+Vue.currentUser.token},
          success: function(result){
            if(addToBoard) {
              _vue.addContactToBoard(userId, companyId, result.data.id, boardId, columnId);
            } else {
              window.location.href='/contact';
            }
          }
        });
      }else{
        alert('Name can\'t be blank');
      }
    },

    cancel: function() {
      this.$emit('hide-new-contact');
    },

    selectContact(con) {
      if(typeof con!=='string') {
        this.existingContactId = con.id;
        this.email = con.email;
        this.phone = con.phone;
        this.addToBoard = true;
      } else {
        this.existingContactId = null;
        this.name = con;
        this.email = null;
        this.phone = null;
      }
    },

    searchContacts(search, loading) {
      loading(true);
      this.$http.get('/api/v2/contact?q='+search, {
        headers: {'Authorization': 'Bearer '+Vue.currentUser.token}
      }).then(resp => {
        this.contacts = resp.data.data;
        loading(false);
      });
    }
  },
  mounted: function() {
    this.loadColumns();
  }
};
</script>
