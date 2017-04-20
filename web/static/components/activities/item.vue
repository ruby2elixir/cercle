<template>
 <tr v-if="!item.is_done">
  <td style="width:30px;">
    <img :src="'/images/letters/' + item.contact.name.slice(0,1).toLowerCase() + '.png'" style="border-radius:14px;" />
  </td>
  <td style="width:150px;">
    <a v-on:click.stop="$emit('contact-show')" href='#' style="color: #565656;"> {{item.contact && item.contact.name}} </a>
  </td>
  <td style="font-size:16px;">
  <a v-on:click.stop="$emit('contact-show')" style="color: #565656;"> <span style=""> {{item.title}}</span> </a><br />
  </td>
  <td style="width:150px;">
    {{item.due_date| moment(timeFormat) }}
  </td>
  <td style="width:30px;">
  <el-checkbox v-model="item.is_done" v-on:change="updateTask(item)"></el-checkbox>
  </td>
</tr>
</template>

<script>
    export default {
      props: {
        'timeFormat': { type: String, default: 'ddd DD MMM @ h:m' },
        item: {
          type: Object,
          default: function() { return {}; }
        }
      },
      methods: {
        updateTask(task) {
          let url = '/api/v2/activity/' + task.id;

          this.$http.put(url, {
            activity: { isDone: task.is_done }
          });

        }
      },
      components: {
        'el-checkbox': ElementUi.Checkbox
      }
};
</script>
<style lang="sass">

</style>
