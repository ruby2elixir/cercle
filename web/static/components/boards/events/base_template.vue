<template>
  <li>
    <a href="#" @click="$emit('clickByEvent')">
      <img :src="item.profileImageUrl" style="max-width:40px;border-radius:40px;float:left;" />
      <div class="menu-info" style="margin-left:55px;">
       <h4 class="control-sidebar-subheading" style="font-size:16px;">
         <span style="font-weight:600;">
           {{item.userName}}
         </span>
         <slot></slot>
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
      return Moment.utc(this.item.createdAt).fromNow();
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
