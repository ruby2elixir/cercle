<template>
  <div class="contact-page-events">
    <div class="event" v-for="event in events">
      <div class="user-block">
        <img v-if="event.user && event.user.profile_image" class="img-circle img-bordered-sm" :src="event.user.profile_image" alt="user image">
        <img v-else class="img-circle img-bordered-sm" src="/images/pp_2.png" alt="user image">
      </div>
      <div class="message-block">
        <div style="padding:5px;font-size:15px;padding-bottom:15px;">
          <span class="username" style="">
            {{ event.user && event.user.user_name }}
          </span>
          <span class="description"> {{event.event_name}} </span>
        </div>
        <div class="well">
          {{event.content}}
        </div>
        <div  class="description" style="color:grey;">
          {{timestamp(event.inserted_at)}}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import moment from 'moment';
  export default {
  props: ['events'],
  methods: {
    timestamp(time) {
      return Moment(time).fromNow()
    }
  },
  computed: {
            profile_image(event) {
            return event.user && event.user.profile_image
            }
  },
  components: {  },
  }
</script>

<style lang="sass">
  .contact-page-events {
  .event {
      padding:5px;
      padding-top:0px;
      margin-bottom:20px;
     .user-block {
       float:left;
       width:45px;
       margin-left:10px;
     }
     .message-block {
       margin-left:60px;
  .well {
     padding:15px;
     font-size:15px;
     color:#292929;
     background-color:white;
     border-radius:5px;
     margin-bottom:5px;
     margin-right:18px;
  }
  }
    }
  }
</style>
