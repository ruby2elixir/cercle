<style>
  a.archive, a.unarchive {
    display: block;
    text-align: center;
    background: lightgray;
    padding: 5px 20px;
    border-radius: 3px;
    color: #333;
    cursor: pointer;
  }

  a.archive:hover, a.unarchive:hover {
    text-decoration: underline;
  }
</style>

<template>
  <div>
    <a v-show="archived == 'false'" class="archive" @click="archive">Archive this board</a>
    <a v-show="archived == 'true'" class="unarchive" @click="unarchive">Restore this board</a>
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
        var url = '/api/v2/board/' + this.boardId + '/archive';
        this.$http.put(url).then(resp => {
          window.location.href = '/board';
        });
      }
    },
    unarchive: function() {
      if(confirm('Are you sure?')) {
        var url = '/api/v2/board/' + this.boardId + '/unarchive';
        this.$http.put(url).then(resp => {
          window.location.reload();
        });
      }
    }
  }
};
</script>
