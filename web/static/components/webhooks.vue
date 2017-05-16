<template>
  <div>
    <div class="box-body">
      <div class="form-group" v-for="webhook in webhooks">
        <label class="control-label">{{webhook.event}}</label>
        <input v-model="webhook.url" v-on:change="save(webhook)" type="text" placeholder="http://www.example.com/hook" class="form-control" />
      </div>
    </div><!-- /.box-body -->
  </div>
</template>

<script>
  export default {
    data() {
      return {
        webhooks: []
      };
    },
    methods: {
      save: function(webhook) {
        if(webhook.url) {
          this.$http.post('/api/v2/webhooks', {webhook_subscription: webhook});
        } else {
          this.$http.delete('/api/v2/webhooks/'+webhook.event);
        }
      }
    },
    mounted() {
      var events = ['card.created', 'card.updated', 'card.deleted', 'contact.created', 'contact.updated', 'contact.deleted'];

      this.$http.get('/api/v2/webhooks').then(resp => {
        for(var i=0; i<events.length; i++) {
          var hook = resp.data.data.find(function(e){
            return e.event === events[i];
          });
          if(!hook) {
            hook = {
              event: events[i],
              url: ''
            };
          }
          this.webhooks.push(hook);
        }
      });
    }
  };
</script>
