<template>
  <button type="button" class="btn btn-danger archive delete" v-on:click="deleteContact">DELETE</button>
</template>

<script>
export default {
  props: ['contact'],
  data() {
    return {
    };
  },
  methods: {
    deleteContact: function(){
      if(confirm('Are you sure do to delete "' + this.contact.name + '"?')) {
        var url = '/api/v2/contact/'+this.contact.id;
        this.$http.delete(url).then(resp => {
          window.location.reload();
        });
      }
    }
  }

};
</script>
