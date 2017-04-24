<template>
  <li>
    <a href="#">
      <img :src="item.profile_image_url" style="max-width:40px;border-radius:40px;float:left;" />
      <div class="menu-info" style="margin-left:55px;">
       <h4 class="control-sidebar-subheading" style="font-size:16px;">
         <span style="font-weight:600;">{{item.user_name}}</span>
         <div>
           {{ item.content }}
         </div>
         <small>{{item.created_at | moment('MMM DD [at] h:m A') }}</small>
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
  mounted() { }
};
  </script>
<style lang="sass">

</style>
