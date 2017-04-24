<template>
  <div class="new-contact" style="padding: 10px;">
    <div class="form-group">
      <input type="text" v-model="name" placeholder="Name" class="form-control" />
    </div>
    <div class="form-group">
      <input type="email" v-model="email" placeholder="Email" class="form-control" />
    </div>
    <div class="form-group">
      <input type="phone" v-model="phone" placeholder="phone" class="form-control" />
    </div>
    <div class="form-group">
      <label>
        <input type="checkbox" v-model="addToBoard" value='1' />
        Add to board
      </label>
    </div>
    <div class="form-group">
      <select v-model="boardId" class="form-control" :disabled="addToBoard!='1'" v-on:change="loadColumns">
        <option v-for="board in boards" :value="board.id">{{ board.name }}</option>
      </select>
    </div>
    <div class="form-group">
      <select v-model="columnId" class="form-control" :disabled="addToBoard!='1'">
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
import vSelect from 'vue-select';
export default {
  props: ['userId', 'companyId', 'boards', 'defaultBoardId'],
  data: function() {
    return {
      name: '',
      email: '',
      phone: '',
      columnId: '',
      columns: [],
      boardId: this.defaultBoardId,
      addToBoard: false
    };
  },
  methods: {
    loadColumns: function() {
      this.columns = [];
      for(var i=0; i<this.boards.length; i++) {
        if(this.boardId == this.boards[i].id) {
          this.columns = this.boards[i].board_columns;
          break;
        }
      }
      if(this.columns.length)
        this.columnId = this.columns[0].id;
    },
    saveContact: function(){
      var jwtToken = document.querySelector('meta[name="guardian_token"]').content;
      if(this.name !== ''){
        var userId = this.userId;
        var companyId = this.companyId;
        var boardId = this.boardId;
        var columnId = this.columnId;
        var addToBoard = this.addToBoard == '1';

        $.ajax('/api/v2/contact', {
          method: 'POST',
          data: {
            'contact[user_id]': userId,
            'contact[company_id]': companyId,
            'contact[name]': this.name,
            'contact[email]': this.email,
            'contact[phone]': this.phone
          },
          headers: {'Authorization': 'Bearer '+jwtToken},
          success: function(result){
            if(addToBoard) {
              var contactId = result.data.id;
              $.ajax( '/api/v2/opportunity/' , {
                method: 'POST',
                headers: {'Authorization': 'Bearer '+jwtToken},
                data: {
                  'opportunity[main_contact_id]': contactId ,
                  'opportunity[contact_ids]': [contactId],
                  'opportunity[user_id]': userId,
                  'opportunity[company_id]': companyId,
                  'opportunity[board_id]': boardId,
                  'opportunity[board_column_id]': columnId,
                  'opportunity[name]': ''
                },
                complete: function(xhr, status){
                  window.location.href='/board/2';
                }
              });
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
    }
  },
  mounted: function() {
    this.loadColumns();
  }
};
</script>
