<template>
  <button type="button" class="btn btn-default archive delete" v-on:click="deleteContact">DELETE CONTACT</button>
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
        var url = '/api/v2/company/'+ Vue.currentUser.companyId +'/contact/'+this.contact.id;
        this.$http.delete(url).then(resp => {
          window.location.reload();
        });
      }
    }
  }

};
</script>
