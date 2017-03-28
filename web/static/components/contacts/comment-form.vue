<template>
  <div class="contact-comments-form">
    <h3><i class="fa fa-fw fa-comments-o"></i>Comment</h3>
    <br />
    <div class="mb=0">
      <img class="img-circle img-bordered-sm" :src="userImg || defaultImg" alt="user image" style="width:40px;float:left;">
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
        defaultImg: '/images/pp_2.png',
        userImg: this.user_image
      };
    },
    methods: {
      sendMessage(){
        var url = '/api/v2/timeline_events';
        this.$http.post(url,
          { timelineEvent: {
            companyId: this.contact.company_id,
            contactId: this.contact.id,
            content: this.message,
            eventName: 'comment',
            opportunityId: this.opportunity.id
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
