<template>
  <span v-on-click-outside='cancel'>
    <span v-on:click="showModal" class='current-value-display'>
      {{ board.name }} - {{ column.name }}
    </span>

    <div v-show="editMode" class='input-modal'>
      <div class='modal-header clearfix'>
        Change Board/Column
        <a class='close pull-right' @click='cancel'>×</a>
      </div>

      <div class='modal-body'>
        <div class="form-group">
          <label>Board</label>
          <select v-model="bId" @change='boardChange'>
            <option v-for="board in boards" :value.number="board.id">{{board.name}}</option>
          </select>
        </div>
        <div class="form-group">
          <label>Column</label>
          <select v-model="cId" ref="column-input">
            <option
              v-for="column in selectedBoard().boardColumns"
              :value.number="column.id">
              {{column.name}}
            </option>
          </select>
        </div>
        <div>
          <button class='btn btn-primary btn-block' @click='save'>Save</button>
        </div>
      </div>
    </div>
  </span>
</template>

<script>
export default {
  props: ['boardId', 'boardColumnId'],
  data() {
    return {
      editMode: false,
      bId: this.boardId,
      cId: this.boardColumnId,
      boards: [],
      boardColumns: []
    };
  },
  watch: {
    'boardId': function() {
      this.bId = this.boardId;
    },
    'boardColumnId': function() {
      this.cId = this.boardColumnId;
    }
  },
  computed: {
    board() {
      return this.boardById(this.boardId) || { name: '--', boardColumns: [] };
    },
    column() {
      return this.$_.find(
        this.board.boardColumns, {id: this.boardColumnId}
      ) || { name: '--' };
    }
  },
  methods: {
    boardById(id) {
      return this.$_.find(this.boards, {id: id});
    },
    selectedBoard() {
      return this.boardById(this.bId) || {boardColumns: []};
    },
    boardChange() {  this.cId = null;  },
    showModal() { this.editMode = true; },
    save() {
      this.$emit('input', {boardId: this.bId, boardColumnId: this.cId});
      this.editMode = false;
    },
    cancel() {
      this.bId = this.boardId;
      this.cId = this.boardColumnId;
      this.editMode = false;
    }
  },
  mounted() {
    this.$http.get('/api/v2/company/'+ Vue.currentUser.companyId +'/board/').then(resp => {
      this.boards = resp.data.data;
    });
  }
};
</script>

<style scoped>
  .current-value-display {
    color:rgb(99,99,99);
    font-weight:bold;
    cursor: pointer;
  }

  .input-modal {
    font-size: 14px;
  }
</style>
