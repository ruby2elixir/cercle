<template>
  <div class="new-card-form">
    <div class="form-group">
      <input type="text" v-model="name" placeholder="Name" class="form-control" />
    </div>
    <div class="form-group">
      <textarea class="form-control" v-model="description" placeholder="Write a description"></textarea>
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
      <button class="btn btn-success" v-on:click="saveCard">Save</button>
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
        boardId: this.defaultBoardId
      };
    },
    components: {
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

      saveCard: function(){
        let url = '/api/v2/card/';
        this.$http.post(url,{
          card: {
            userId: this.userId,
            companyId: this.companyId,
            boardId: this.boardId,
            boardColumnId: this.columnId,
            name: this.name,
            description: this.description
          }
        });
      },

      cancel: function() {
        this.$emit('close');
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
