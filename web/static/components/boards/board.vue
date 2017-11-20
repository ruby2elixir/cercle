<template>
  <div class='board-page'>
    <section class="content-header clearfix">
      <h2 class="">
        <inline-edit v-model="board.name" v-on:input="updateBoard" placeholder="Board Name" class='board-name'></inline-edit>
      </h2>
      <button class='btn btn-default' @click="newCard()" v-if="board.boardColumns && board.boardColumns.length > 0">
        <span class="add-card">+ Add card</span>
      </button>
    </section>

    <!-- Main content -->
    <div id="columns-container" class="columns-container">
      <div id="board_columns">
        <vue-draggable v-model="board.boardColumns" element="span" @end="onEndMoveBoardColumn">
          <transition-group name="flip-list"  class="list-group">
            <div class="column_master" v-for="col in board.boardColumns" :key="col.id">
              <div class="column_title" style="position:relative;">
                <inline-text-edit
                  v-model.trim="col.name"
                  v-on:input="updateBoardColumn(col)"
                  placeholder="Column Name"
                  class='board-column-name textarea-inline-editable'>
                </inline-text-edit>

                <el-dropdown v-if="canDeleteColumn(col)">
                  <span class="el-dropdown-link fa fa-ellipsis-h"></span>
                  <el-dropdown-menu slot="dropdown">
                    <el-dropdown-item>
                      <a @click="deleteColumn(col)">Delete This Column..</a>
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </el-dropdown>
              </div>
              <br />

              <div class="column" :data-id="col.id">
                <vue-draggable
                  v-model="col.cards"
                  :options="{group:'cards'}"
                  @change="onEndMoveCard(col, $event)"
                  element="div">
                  <transition-group name="flip-list"  class="list-group">
                    <div class="portlet"
                         v-for="card in col.cards"
                         :key="card.id"
                         :column_id="col.id">
                        <router-link :to="cardUrl(card)" tag='div' class='portlet-content'>
                          <span class='name'>
                            <div>
                              <span v-if="card.mainContact">
                                {{card.mainContact.name}}
                                <span v-if="card.name" class="contact-name">
                                  - {{card.name}}
                                </span>
                              </span>
                              <span v-else>{{card.name}}</span>
                            </div>
                            <img :src="card.user.profileImageUrl"
                                 class='profile-image'
                                 style="max-width:25px;max-height:30px;margin-top:10px;border-radius:4px;"
                                 :title="card.user.userName" v-if="card.user"  />

                          </span>
                        </router-link>
                    </div>
                  </transition-group>
                </vue-draggable>
              </div>

            </div>
          </transition-group>
        </vue-draggable>

        <div class="column_master" id="add_new_column">
          Add a new Column
          <input type="text" v-model.trim="newColumn.name" placeholder="Name of the Column" />
          <br />
          <input type="submit" value="Save" class="btn btn-success" @click="addColumn"/>
        </div>

      </div>
    </div><!-- /.content -->

  </div>
</template>
<script>
import {Socket, Presence} from 'phoenix';
import InlineEdit from '../shared/inline-common-edit.vue';
import InlineTextEdit from '../shared/inline-textedit.vue';
import ContactShow from '../contacts/show.vue';
import NewContact from '../contacts/new.vue';

export default {
  props: ['board_id'],
  data() {
    return {
      board: {},
      contact: {},
      card: {},
      newColumn: {},
      channel: null
    };
  },
  beforeRouteEnter (to, from, next) {
    document.querySelector('.main-header').scrollIntoView(true);
    next(vm => {
      if (to.name === 'cardPage') { vm.cardShow(to.params.cardId); }
    });
  },
  beforeRouteLeave (to, from, next) {
    this.$glmodal.$off('onCloseModal');
    next();
  },
  watch: {
    '$route' (to, from) {
      if (to.name === 'cardPage') { this.cardShow(to.params.cardId); }
      if (from.name === 'cardPage') { this.$glmodal.$emit('close'); }
    }
  },
  components: {
    'inline-edit': InlineEdit,
    'inline-text-edit': InlineTextEdit,
    'modal': VueStrap.modal,
    'contact-show': ContactShow,
    'new-contact': NewContact,
    'vue-draggable': VueDraggable,
    'dropdown': VueStrap.dropdown
  },
  methods: {
    canDeleteColumn(column) {
      return !(column.cards && column.cards.length > 0 );
    },
    cardUrl(card) {
      return '/company/' + Vue.currentUser.companyId + '/board/' + this.board.id + '/card/' + card.id;
    },
    addColumn() {
      if (this.newColumn.name && this.newColumn.name !== '') {
        let url = this.buildApiUrl('/board_column');
        this.$http.post(url, {
          boardColumn: {
            boardId: this.board.id,
            name: this.newColumn.name
          }
        });
        this.newColumn = {};
      }
    },
    deleteColumn(column) {
      if(confirm('Are you sure?')) {
        let url = this.buildApiUrl('/board_column/' + column.id);
        this.$http.delete(url).then(resp => {
          let itemIndex = this.board.boardColumns.findIndex(function(item){
            return item.id === parseInt(column.id);
          });
          if (itemIndex !== -1){ this.board.boardColumns.splice(itemIndex, 1); }
        }, error => {
          this.$notification.$emit('alert', { msg: error.body.reason, type: 'danger' });
        });
      }
    },
    onEndMoveCard(column, event) {
      if (event.added) {
        let card = event.added.element;
        let position = event.added.newIndex;
        let url = this.buildApiUrl('/card/' + card.id);
        this.$http.put(url, {
          card: { position: position, boardColumnId: column.id}
        }).then( resp => {
          let reorderUrl = this.buildApiUrl('/board_column/' + column.id + '/reorder_cards');
          let cardIds = column.cards.map((v)=> v.id);
          this.$http.put(reorderUrl, { cardIds: cardIds });
        });
      } else if (event.removed) {

      } else if (event.moved) {
        let url = this.buildApiUrl('/board_column/' + column.id + '/reorder_cards');
        let cardIds = column.cards.map((v)=> v.id);
        this.$http.put(url, { cardIds: cardIds });

      }
    },
    onEndMoveBoardColumn(e) {
      let url = this.buildApiUrl('/board/' + this.board.id + '/reorder_columns');
      let columnIds = this.board.boardColumns.map((v)=> v.id);
      this.$http.put(url, { orderColumnIds: columnIds });
    },
    updateBoardColumn(boardColumn) {
      let url = this.buildApiUrl('/board_column/' + boardColumn.id);
      this.$http.put(url, {id: boardColumn.id, boardColumn: { name: boardColumn.name.trim() } });
    },
    updateBoard() {
      this.$http.put(this.boardUrl, {id: this.board.id, board: { name: this.board.name } });
    },
    newCard() {
      this.$glmodal.$emit(
        'open', {
          view: 'new-card-form',
          class: 'new-card-modal',
          title: 'Add a card into this board',
          'closed_in_header': true,
          size: 'medium',
          'display_header': true,
          'autofocus': true,
          data: {
            'board-id': this.board.id,
            'columns': this.board.boardColumns,
            'user-id': Vue.currentUser.userId,
            'company-id': this.board.companyId,
            'type': this.board.typeOfCard
          }
        });
    },
    newContact(boards, companyId) {
      this.$glmodal.$emit(
        'open', {
          view: 'new-contact-form',
          class: 'new-contact-modal',
          title: 'Add a contact into this board',
          'closed_in_header': true,
          size: 'small',
          'display_header': true,
          data: {
            'board_id': this.board_id,
            'default-board-id': this.board_id,
            'user-id': Vue.currentUser.userId,
            'company-id': companyId,
            boards: boards
          }
        });
    },
    cardShow(cardId) {
      let vm = this;
      vm.$glmodal.$off('onCloseModal');
      vm.$glmodal.$once('onCloseModal', function() {
        vm.$router.push({
          path: `/company/${vm.board.companyId}/board/${vm.board_id}`
        });
      });
      this.$glmodal.$emit(
        'open', {
          view: 'card-show', class: 'card-modal', data: { 'cardId': cardId }
        });
    },
    changeContactDisplay(contactId) {
      this.contact = { id: contactId };
    },
    initChannel() {
      this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
      this.socket.connect();
      this.channel = this.socket.channel('board:' + this.board_id, {});
      this.channel.join()
        .receive('ok', resp => {  })
        .receive('error', resp => { console.log('Unable to join', resp); });

      this.channel.on('board:updated', payload => {
        let _payload = this.camelCaseKeys(payload);
        this.board = _payload.board;
      });
    },
    initComponent() {
      this.$http.get(this.boardUrl).then(resp => {
        this.$parent.$refs.boardSidebar.setBoardStatus(resp.data.data.archived);
        this.board = resp.data.data;
      });
    },
    buildApiUrl(path) { return '/api/v2/company/' + Vue.currentUser.companyId + path; }

  },
  computed: {
    boardUrl() {
      return this.buildApiUrl('/board/' + this.board_id);
    }
  },
  mounted() {
    this.initComponent();
    this.initChannel();


  }
};
  </script>
<style lang="sass">
  .el-dropdown-menu {
    border-radius: 4px !important;
    padding-top: 1px !important;
    padding-bottom: 1px !important;
    a {     color: #333; }
    }
  .board-page {
    .column {
      .list-group {
        min-height: 25px;
        display: inline-block;
        min-width: 100%;
      }
    }
    .el-dropdown {
      position: absolute;
      right: 2px;
      top: 2px;
      width: 18px;
      height: 18px;
      color: grey;
      font-size: 12px;
    }
    .flip-list-move {
      transition: transform 1s;
    }
    .content-header {
      margin-bottom: 20px;
      margin-left: 20px;
      .board-name {
        color: white;
        font-weight: bold;
      }
    }
    .portlet {
      background-color: white;
      border-radius: 4px;
      font-size: 14px;
      font-weight: 800;
      padding-bottom: 10px;
      cursor: pointer;
      margin: 0 1em 1em 0;
      padding: .3em;
    }
    .portlet-content {
      font-family: Verdana,Arial,sans-serif;
      font-size: 14px;
      font-weight: 800;
      padding-bottom: 10px;
      cursor: pointer;
      .name { color: #222222; }
      .contact-name { color: rgb(119, 119, 119); }
    }
    .add-card {
      font-weight: bold;
      font-size: 16px;
    }
    .profile-image {
      border-radius: 50%;
      max-width: 20px;
      max-height: 20px;
    }
  }
</style>
