<template>
 <tr>
  <td style="width:30px;">
    <img :src="letterUrl" style="border-radius:14px;" />
  </td>
  <td style="width:150px;">
    <a v-on:click.stop="$emit('contact-show')" href='#' style="color: #565656;"> {{item.contact && item.contact.name}} </a>
  </td>
  <td style="font-size:16px;">
  <a v-on:click.stop="$emit('contact-show')" style="color: #565656;"> <span style=""> {{item.title}}</span> </a><br />
  </td>
  <td style="width:150px;">
    {{item.due_date_with_current_timezone| moment(timeFormat) }}
  </td>
  <td style="width:30px;">
  <el-checkbox v-model="item.is_done" v-on:change="updateTask(item)"></el-checkbox>
  </td>
</tr>
</template>

<script>
    export default {
      props: {
        'timeFormat': { type: String, default: 'ddd DD MMM @ HH:mm' },
        item: {
          type: Object,
          default: function() { return {}; }
        }
      },
      computed: {
        letterUrl: function() {
          let letter = 'n';
          if (this.item.contact.first_name) {
            letter = this.item.contact.first_name.slice(0,1).toLowerCase();
          }
          return  '/images/letters/' + letter + '.png';
        }
      },
      methods: {
        updateTask(task) {
          let url = '/api/v2/activity/' + task.id;

          this.$http.put(url, {
            activity: { isDone: task.is_done }
          }).then(_ => { this.$emit('done', task) } );

        }
      },
      components: {
        'el-checkbox': ElementUi.Checkbox
      }
};
</script>
<style lang="sass">

</style>
