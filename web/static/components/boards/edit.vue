<template>
  <div class='board-container'>
    <div class='board-header' >
      <h2 style="margin-bottom:20px;font-size:24px;">Name of the Board</h2>
    </div>

    <div class='board-form-container' style="min-height:800px;">
      <div class='board-form-content'>
        <div style="margin-bottom:10px;">
          <input v-model="board.name" type="text"
                 placeholder="Name of the board"
                 style="padding:5px;width:200px;"
                 class="board_name" >
        </div>

        <br />

        <div class="row" style="font-size:17px;line-height: 30px;">
          <div class="col-sm-3">
            <el-radio v-model="board.typeOfCard" label="0" >&nbsp;&nbsp;Project Board</el-radio>
            <br />
            <i>Track Tasks</i>
          </div>
          <div class="col-sm-9">
            <el-radio v-model="board.typeOfCard" label="1" >&nbsp;&nbsp;People Board</el-radio>
            <br />
            <i>Track People, Clients, Prospects, Deals</i>
          </div>
        </div>

        <Br />
      </div>
      <button class="btn btn-primary" @click="updateBoard" >UPDATE</button>
    </div>
  </div>
</div>

</template>
<script>
  export default {
    props: ['companyId', 'boardId'],
    data() {
      return {
        board: {}
      };
    },
    components: {
      'el-radio': ElementUi.Radio
    },
    methods: {
      updateBoard() {
        let url ='/api/v2/company/' + this.companyId + '/board/' + this.boardId;
        let boardsUrl = '/company/' + this.companyId + '/board';
        this.$http.put(url, {board: this.board  }).then( resp => {
          this.$router.push(boardsUrl);
        });
      }
    },
    mounted() {
      let url ='/api/v2/company/' + this.companyId + '/board/' + this.boardId;
      this.$http.get(url).then(resp => {
        this.board = resp.data.data;
        this.board.typeOfCard = this.board.typeOfCard.toString();
      });
    }
  };
</script>
<style lang="sass">
</style>
