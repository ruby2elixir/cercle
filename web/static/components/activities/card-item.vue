<template>
  <tr>
    <td><span>{{item.name}}</span></td>
    <td style="width:150px;" class="text-right">{{columnName}}</td>
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
        return this.item.boardColumn && this.item.boardColumn.name
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
