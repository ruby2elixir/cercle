<template>
  <div class="contact-comments-form">
    <h3><i class="fa fa-fw fa-comments-o"></i>Comment</h3>
    <br />
    <div style="margin-bottom:0px;">
      <img class="img-circle img-bordered-sm" src="/images/pp_2.png" alt="user image" style="width:40px;float:left;">
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
    props: [],
    data(){
      return {
        message: ''
      };
    },
    methods: {
      sendMessage(){
        this.$emit('submit', this.message);
        this.message = '';
      }
    },
    components: {
    }
  };
</script>

<style lang="sass">
  .contact-comments-form {
    h3 {
      margin-top:0px;
      border-bottom:0px solid #d8d8d8;
        i {
          color:#d8d8d8;
        }
    }
    .message-block {
      margin-left:50px;
      margin-right:10px;
      textarea {
        height:70px;
      }
    }
  }
</style>
