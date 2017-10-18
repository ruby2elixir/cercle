<template>
 <tr>
  <td style="width:30px;">
    <img :src="letterUrl" style="border-radius:14px;" />
  </td>
  <td style="font-size:16px;">
    <a v-on:click.stop="$emit('card-show')" style="color: #565656;">
      <span class="activity-name"> {{item.title || ('Task#' + item.id) }}</span>
    </a>
  </td>
  <td style="width:150px;">
    {{item.dueDateWithCurrentTimezone| moment(timeFormat) }}
  </td>
  <td style="width:30px;">
    <el-checkbox v-model="item.isDone"
                 v-on:change="updateTask(item)"></el-checkbox>
  </td>
</tr>
</template>

<script>
    export default {
      props: {
        'timeFormat': { type: String, default: 'ddd DD MMM HH:mm' },
        item: {
          type: Object,
          default: function() { return {}; }
        }
      },
      computed: {
        letterUrl: function() {
          let letter = 'n';
          if (this.item.card.name) {
            letter = this.item.card.name.slice(0,1).toLowerCase();
          }
          return  '/images/letters/' + letter + '.png';
        }
      },
      methods: {
        updateTask(task) {
          let url = '/api/v2/company/' + Vue.currentUser.companyId + '/activity/' + task.id;

          this.$http.put(url, {
            activity: { isDone: task.isDone }
          }).then(_ => { this.$emit('done', task); } );

        }
      },
      components: {
        'el-checkbox': ElementUi.Checkbox
      }
};
</script>
<style lang="sass">

</style>
