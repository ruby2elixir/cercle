<template>
  <li>
    <a href="#">
      <img :src="item.profile_image_url" style="max-width:40px;border-radius:40px;float:left;" />
      <div class="menu-info" style="margin-left:55px;">
       <h4 class="control-sidebar-subheading" style="font-size:16px;">
         <span style="font-weight:600;">
           {{item.user_name}}
         </span>
         <a :href="'/contact/' + contact.id" v-for="contact in meta.contacts">{{contact.first_name}} {{contact.last_name}}</a>
         to <a :href="'/board/' + item.board_id">{{toName}}</a>
         <br />
         <small>{{timestamp}}</small>
       </h4>
     </div>
    </a>
   </li>
</template>
<script>
import moment from 'moment';
export default {
  props: ['item'],
  methods: { },
  computed: {
        timestamp: function() {
            return Moment.utc(this.item.created_at).fromNow();
        },
      meta: function() {
          return this.item.metadata
      },
      toName: function() {
          let bName = []
          if (this.meta && this.meta.board) {
              bName.push(this.meta.board.name)
          }
          if (this.meta && this.meta.board_column) {
              bName.push(this.meta.board_column.name)
              }
          return bName.join(' - ')
      }

    },
  mounted() { }
};
  </script>
<style lang="sass">
  .comment-message {
  padding: 9px 11px;
  background-color: #fff;
  border-radius: 3px;
  box-shadow: 0 1px 2px rgba(0,0,0,.23);
  -moz-box-sizing: border-box;
  box-sizing: border-box;
  clear: both;
  cursor: pointer;
  display: inline-block;
  margin: 6px 2px 6px 0;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
  }
</style>
