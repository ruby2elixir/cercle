<style>
  a.unarchive {
    display: block;
    text-align: center;
    background: lightgray;
    padding: 5px 20px;
    border-radius: 3px;
    color: #333;
    cursor: pointer;
  }

  a.unarchive:hover {
    text-decoration: underline;
  }
</style>

<template>
  <div>
    <a class="unarchive" @click="archive">Restore this board</a>
  </div>
</template>

<script>
import vSelect from 'vue-select';
export default {
  props: ['boardId'],
  data: function() {
    return {
    };
  },
  methods: {
    archive: function() {
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
