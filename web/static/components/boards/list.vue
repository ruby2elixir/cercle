<template>
  <div>

    <div class="board-list-app row">
      <router-link
        :to="boardUrl(board)"
        v-for="board in boards"
        v-if="showBoard(board)"
        v-bind:class="{archived: board.archived}"
        class="board col-md-3 col-sm-6 col-xs-12 "
        >
        {{board.name}}
      </router-link>
        <a :href="newBoardUrl()" class="col-md-3 col-sm-6 col-xs-12 add-board"> + Add a board</a>
    </div>
    <div class="boards-actions">
      <span v-if="!archived" @click="archived = true">
        Archived boards
      </span>
      <span v-if="archived" @click="archived = false">
        Hide archived boards
      </span>
    </div>

  </div>
</template>
<script>
  export default {
  props: [],
  data() {
  return {
  boards: [],
  archived: false
  };
  },
    beforeRouteEnter (to, from, next) {
      document.querySelector('.content-wrapper').classList.remove('board');
      document.querySelector('.wrapper').classList.remove('wrapper_board');
      next();
    },
    watch: {
      archived() {
        this.loadBoards();
      }
    },
    methods: {
      boardUrl(board) {
        return '/company/' + Vue.currentUser.companyId + '/board/'+board.id;
      },
      newBoardUrl(board) {
        return '/company/' + Vue.currentUser.companyId + '/board/new';
      },
      showBoard(board) {
        if (this.archived) {
          return true;
        } else {
          return !board.archived;
        }
      },
  loadBoards() {
    let url = '/api/v2/company/' + Vue.currentUser.companyId + '/board';
    let params = {};
    if (this.archived) {
      params['archived'] = true;
    }
    this.$http.get(url, {params: params}).then(resp => {
      this.boards = resp.data.data;
    });
  }
  },
  mounted() {
  this.loadBoards();
  }
  };
</script>
<style lang="sass">

  .boards-actions {
      margin-left:5px;
      span {
        color: #333;
        cursor: pointer;
      }

    }
  .board-list-app {
  margin-top:50px;
  .archived {
  opacity: .5;
  }
  .board {
    background-color:#151148;
    color:white;
    height:100px;
    font-size:23px;
    font-weight:bold;
    padding:10px;
    padding-left:10px;
    margin:20px;
  cursor:pointer;
  a {
  color: white;
  }
  }
  .add-board {
    background-color:black;
    color: white;
    height: 100px;
    font-size:23px;
    font-weight:bold;
    padding:10px;
    padding-left:10px;
    margin:20px;
    cursor:pointer;
  }
}
  </style>
