<template>
      <aside class="control-sidebar control-sidebar-light" >
        <!-- Create the tabs -->
        <!-- Tab panes -->
        <div class="tab-content">
          <h3>
            <button @click="close" type="button" class="close" aria-label="Close" id="close-sidebar" >
              <span aria-hidden="true">&times;</span>
            </button>
          </h3>
          <br/>
          <br/>
          <div style="margin-bottom:10px;">
            <a class="edit-board"
              :href="editBoardUrl">
              Edit Board
            </a>
          </div>
          <div id="archive-board">
            <archive-board board-id="board_id" archived="false" />
          </div>

          <div id="recent-activities-app">
            <activities :board_id="board_id"/>
          </div>
        </div>
      </aside>

</template>
<script>
  import ArchiveBoard from './archive.vue';
  import BoardRecentActivities from './recent_timeline_events.vue';
  export default {
    props: ['board_id'],
    data() {
      return {};
    },
    components: {
      'archive-board': ArchiveBoard,
      'activities': BoardRecentActivities
    },

    computed: {
      editBoardUrl() {
        return '/company/' + Vue.currentUser.companyId + '/board/'+this.board_id+'/edit';
      }
    },
    methods: {
      close() {
        let elem = document.querySelector('.control-sidebar-light');
        elem.classList.toggle('open');
        let menu = document.querySelector('.board-sidebar-toogle');
        menu.classList.toggle('open');
      }
    }
  };
</script>
<style lang="sass">
  .edit-board {
  display: block;
  text-align: center;
  background: white;
  padding: 5px 20px;
  border-radius: 3px;
  color: #333;
  cursor: pointer;
  border:1px solid #e2e2e2;
  }
</style>
