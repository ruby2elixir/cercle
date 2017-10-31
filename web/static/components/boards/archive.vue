<style>
  a.archive, a.unarchive {
    display: block;
    text-align: center;
    background: white;
    padding: 5px 20px;
    border-radius: 3px;
    color: #333;
    cursor: pointer;
    border:1px solid #e2e2e2;
  }

  a.archive:hover, a.unarchive:hover {
    text-decoration: underline;
  }
</style>

<template>
  <div>
    <a v-if="!archived" class="archive" @click="archive">Archive board</a>
    <a v-if="archived" class="unarchive" @click="unarchive">Restore board</a>
  </div>
</template>

<script>
import vSelect from 'vue-select';
export default {
  props: ['boardId', 'archived'],
  data: function() {
    return {

    };
  },
  methods: {
    archive: function() {
      if(confirm('Are you sure?')) {
        var url = '/api/v2/company/' + Vue.currentUser.companyId + '/board/' + this.boardId + '/archive';
        this.$http.put(url).then(resp => {
          window.location.href = '/company/' + Vue.currentUser.companyId + '/board';
        });
      }
    },
    unarchive: function() {
      if(confirm('Are you sure?')) {
        var url = '/api/v2/company/' + Vue.currentUser.companyId + '/board/' + this.boardId + '/unarchive';
        this.$http.put(url).then(resp => {
          window.location.reload();
        });
      }
    }
  }

};
</script>
