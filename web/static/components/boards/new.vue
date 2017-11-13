<template>
  <div class='board-container'>
    <div class='board-header' >
      <h2 style="margin-bottom:20px;font-size:24px;">Create a new board</h2>
    </div>

    <div class='board-form-container' style="min-height:800px;">
      <div class='board-form-content'>
        <div style="margin-bottom:10px;">
          <input v-model="boardName" type="text"
                 placeholder="Name of the board"
                 style="padding:5px;width:200px;"
                 class="board_name" >
        </div>

        <br />

        <div class="row" style="font-size:17px;line-height: 30px;">
          <div class="col-sm-3">
            <el-radio v-model="typeOfCard" label="0" >&nbsp;&nbsp;Project Board</el-radio>
            <br />
            <i>Track Tasks</i>
          </div>
          <div class="col-sm-9">
            <el-radio v-model="typeOfCard" label="1" >&nbsp;&nbsp;People Board</el-radio>
            <br />
            <i>Track People, Clients, Prospects, Deals</i>
          </div>
        </div>

        <Br />
      </div>
      <button class="btn btn-primary" @click="createBoard" >CREATE</button>
    </div>
  </div>
</div>

</template>
<script>
  export default {
    props: ['companyId'],
    data() {
      return {
        boardName: '',
        typeOfCard: '0'
      };
    },
    components: {
      'el-radio': ElementUi.Radio
    },
    methods: {
      createBoard() {
        let vm = this;
        let url ='/api/v2/company/' + this.companyId + '/board';
        let boardsUrl = '/company/' + this.companyId + '/board';
        this.$http.post(url, {
          board: { name: this.boardName, typeOfCard: this.typeOfCard }
        }).then( resp => {
          this.$router.push(boardsUrl);
        });
      }
    }
  };
</script>
<style lang="sass">
</style>
