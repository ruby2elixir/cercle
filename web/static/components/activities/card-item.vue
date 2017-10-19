<template>
  <tr>
    <td>
      <a v-on:click.stop="$emit('card-show')" style="color: #565656;">
        <span class="card-name">{{item.name}}</span>
      </a>
    </td>

    <td style="width:150px;" class="text-left">{{columnName}}</td>
  </tr>
</template>

<script>
  export default {
    props: {
      item: {
        type: Object,
        default: function() { return {}; }
      }
    },
    computed: {
      columnName() {
        return this.item.boardColumn && this.item.boardColumn.name;
      }
    },
    methods: {

    },
    components: {
      'el-checkbox': ElementUi.Checkbox
    }
  };
  </script>
<style lang="sass">

</style>
