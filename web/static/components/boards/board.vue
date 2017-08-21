<script>
  import {Socket, Presence} from 'phoenix';
  import InlineEdit from '../inline-common-edit.vue';
  import InlineTextEdit from '../inline-textedit.vue';
  import ContactShow from '../contacts/show.vue';
  import NewContact from '../contacts/new.vue';

  export default {
    props: ['board_id'],
    data() {
      return {
        board: {},
        contact: {},
        card: {},
        newColumn: {}
      };
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
      addColumn() {
        if (this.newColumn.name && this.newColumn.name !== '') {
          let url = '/api/v2/board_column';
          this.$http.post(url, {
            boardColumn: {
              boardId: this.board.id,
              name: this.newColumn.name
            }
          }).then(resp => {
            let boardColumn = resp.data.data;
            boardColumn.cards = [];
            this.board.boardColumns.push(boardColumn);
          });
          this.newColumn = {};
        }
      },
      deleteColumn(column) {
        if(confirm('Are you sure?')) {
          let url = '/api/v2/board_column/' + column.id;
          this.$http.delete(url).then(resp => {
            let itemIndex = this.board.boardColumns.findIndex(function(item){
              return item.id === parseInt(column.id);
            });
            if (itemIndex !== -1){ this.board.boardColumns.splice(itemIndex, 1); }
          });
        }
      },
      onEndMoveCard(column, event) {
        if (event.added) {
          let card = event.added.element;
          let position = event.added.newIndex;
          let url = '/api/v2/card/' + card.id;
          this.$http.put(url, {
              card: { position: position, boardColumnId: column.id}
          }).then( resp => {
              let url = '/api/v2/board_column/' + column.id + '/reorder_cards';
              let cardIds = column.cards.map((v)=> v.id);
              this.$http.put(url, { cardIds: cardIds });
          });
        } else if (event.removed) {

        } else if (event.moved) {
          let url = '/api/v2/board_column/' + column.id + '/reorder_cards';
          let cardIds = column.cards.map((v)=> v.id);
          this.$http.put(url, { cardIds: cardIds });

        }
      },
      onEndMoveBoardColumn(e) {
        let url = '/api/v2/board/' + this.board.id + '/reorder_columns';
        let columnIds = this.board.boardColumns.map((v)=> v.id);
        this.$http.put(url, { orderColumnIds: columnIds });
      },
      updateBoardColumn(boardColumn) {
        let url = '/api/v2/board_column/' + boardColumn.id;
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
                data: {
                  'board_id': this.board.id,
                  'default-board-id': this.board.id,
                  'user-id': Vue.currentUser.userId,
                  'company-id': this.board.companyId,
                  boards: [this.board]
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
        //this.card = { id: cardId };
        this.$glmodal.$emit(
          'open', {
            view: 'card-show', class: 'card-modal', data: { 'cardId': cardId }
          });
      },
      changeContactDisplay(contactId) {
        this.contact = { id: contactId };
      },
      initComponent() {
        this.$http.get(this.boardUrl).then(resp => {
          this.board = resp.data.data;
        });
      }
    },
    computed: {
      boardUrl() {
        return '/api/v2/board/' + this.board_id;
      }
    },
    mounted() {
      this.initComponent();
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

#board-app {
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
    margin-bottom:20px;
    margin-left:20px;
   .board-name {
     color:white;
     font-weight:bold;
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
             font-size:14px;
               font-weight:800;
               padding-bottom:10px;
               cursor:pointer;
               .name {color:#222222; }
               .contact-name { color:rgb(119, 119, 119); }
              }
  .add-card {
    font-weight:bold;
    font-size: 16px;
  }
  }
</style>
