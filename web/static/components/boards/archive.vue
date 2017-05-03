<style>
  a.archive {
    display: block;
    text-align: center;
    background: lightgray;
    padding: 5px 20px;
    border-radius: 3px;
    color: #333;
    cursor: pointer;
  }

  a.archive:hover {
    text-decoration: underline;
  }
</style>

<template>
  <div>
    <a class="archive" @click="archive">Archive this board</a>
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
        var url = '/api/v2/board/' + this.boardId + '/archive';
        this.$http.put(url).then(resp => {
          window.location.href = '/board';
        });
      }
    }
  }
};
</script>
