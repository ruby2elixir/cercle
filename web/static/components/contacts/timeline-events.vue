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
          <markdown-text-edit v-model="event.content" v-on:input="updateEvent(event)" ></markdown-text-edit>
        </div>
        <div  class="description" style="color:grey;">
          {{timestamp(event.inserted_at)}}
          <span class="" v-if="canManage(event)">
            -
            <span @click="deleteEvent(event)" class="timeline_event_delete">
              Delete
            </span>
          </span>
        </div>

      </div>
    </div>
  </div>
</template>

<script>
  import moment from 'moment';
  import MarkdownTextEdit from '../markdown-textedit.vue';
  export default {
    props: ['events'],
    methods: {
      timestamp(time) {
        return Moment.utc(time).fromNow();
      },
      canManage(event) {
        return Vue.currentUser.eq(event.user_id);
      },
      deleteEvent(event) {
        let url = '/api/v2/timeline_events/' + event.id;
        this.$http.delete(url).then(resp => { this.$emit('eventDelete', event.id);});
      },
      updateEvent(event) {
        let url = '/api/v2/timeline_events/' + event.id;
        this.$http.put(url, { timelineEvent: { content: event.content } });
      }
    },
    computed: { },
    components: {
      'markdown-text-edit': MarkdownTextEdit
    }
  };
  </script>
<style lang="sass">
  .timeline_event_delete {
  margin-left: 0px;
  text-decoration: underline;
  cursor: pointer;
  }

  .timeline_event_edit {
  float: right;
  margin-right: 14px;
  }
</style>
