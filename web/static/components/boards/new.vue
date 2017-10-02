<template>
  <div>
    <div @click="showAddMode" class="col-md-3 col-sm-6 col-xs-12 bg-black add-button add-board" v-show="!addMode">
      + Add a board
    </div>
    <div class="col-md-3 col-sm-6 col-xs-12 bg-primary board-box" v-show="addMode">
      <inline-text-edit v-model="name" placeholder="Name" ref="inline-text-input" />
      <br />
      <button class="btn btn-success" @click="save">Save</button>
      <a href="#" class="cancel-link" @click.stop="cancel">Cancel</a>
    </div>
  </div>
</template>

<script>
  import InlineTextEdit from '../shared/inline-textedit.vue';
  export default {
    props: [],
    data: function() {
      return {
        addMode: false,
        name: ''
      };
    },
    components: {
      'inline-text-edit': InlineTextEdit
    },
    methods: {
      showAddMode() {
        this.addMode = true;
        let vm = this;
        Vue.nextTick(function(){
          vm.$refs['inline-text-input'].$refs['input'].focus();
        });
      },
      cancel() {
        this.addMode = false;
      },
      save() {
        let url = '/api/v2/company/' + Vue.currentUser.companyId + '/board';
        this.$http.post(url, {board: {name: this.name}}).then(resp => {
          window.location.reload();
        });
      }
    }
  };
</script>

<style scoped lang="sass">
  .add-button {
    height:100px;
    font-size:23px;
    font-weight:bold;
    padding:10px;
    padding-left:10px;
    margin:20px;
    cursor:pointer;
  }

  .board-box {
    height:100px;
    font-size:23px;
    font-weight:bold;
    padding:10px;
    padding-left:10px;
    margin:20px;
  }

  .cancel-link {
    font-size: 14px;
    color: #fff;
  }

  textarea {
    max-height: 50px;
    &::placeholder {
      color: #ddd;
    }
  }
</style>
