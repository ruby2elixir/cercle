<template>
  <div class="contact-page-events">
    <div class="event" v-for="event in events">
      <div class="user-block">
        <img v-if="event.user && event.user.profile_image" class="img-circle img-bordered-sm" :src="event.user.profile_image_url" alt="user image">
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
        return Moment(time).fromNow();
      }
    },
    computed: {
    },
    components: {  }
  };
</script>
