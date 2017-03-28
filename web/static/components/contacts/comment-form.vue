<template>
  <div class="contact-comments-form">
    <h3><i class="fa fa-fw fa-comments-o"></i>Comment</h3>
    <br />
    <div class="mb=0">
      <img class="img-circle img-bordered-sm" :src="user_img || default_img" alt="user image" style="width:40px;float:left;">
      <div class="message-block">
        <textarea class="form-control" v-model="message" placeholder="Write a comment.."></textarea>
        <br />
        <button class="btn btn-primary" v-on:click="sendMessage">Send</button>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    props: ['contact', 'opportunity', 'user_image'],
    data(){
      return {
        message: '',
        default_img: '/images/pp_2.png',
        user_img: this.user_image
      };
    },
    methods: {
      sendMessage(){
        var url = '/api/v2/timeline_events';
        this.$http.post(url,
          { timeline_event: {
            company_id: this.contact.company_id,
            contact_id: this.contact.id,
            content: this.message,
            event_name: 'comment',
            opportunity_id: this.opportunity.id
          }
          }
                       );

        this.message = '';
      }
    },
    components: {
    }
  };
</script>
