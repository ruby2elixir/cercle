<template>
  <div class="card-comments-form">
    <h3 style="color:rgb(99,99,99);font-weight:bold;"><i class="fa fa-fw fa-comments-o"></i>Comment</h3>
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
    props: ['card', 'userImage'],
    data(){
      return {
        message: '',
        defaultImg: '/images/pp_2.png',
        userImg: this.userImage
      };
    },

    methods: {
      sendMessage(){
        let url = '/api/v2/timeline_events';
        this.$http.post(url, {
          timelineEvent: {
            content: this.message,
            eventName: 'comment',
            cardId: this.card.id
          }
        }).then(resp => { this.$emit('eventAddOrUpdate', resp.data.data); });

        this.message = '';
      }
    },
    components: {
    }
  };
</script>