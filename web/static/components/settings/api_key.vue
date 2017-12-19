<template>
  <div class="box box-primary">
    <div class="box-body">
          <div class="row">
            <div class="col-md-12" style="">
              <h4>Integration</h4>
           	    Cercle CRM is fully compatible with <a href="http://www.zapier.com">Zapier</a>.
                <br />
                <br />

                You can also use this API KEY to use the Cercle API:
                <br />
                <textarea>{{keys.token}}</textarea>
              <br />
              <br />
              API Endpoint to keep a copy of all your emails with Postmark:
              <textarea>{{postmarkUrl}}</textarea>
            </div>
          </div>
        </div>
  </div>
</template>
<script>
  export default {
    props: ['companyId'],
    data() {
      return {
        keys: {}
      };
    },
    methods: {
      fetchKeys() {
        let url = '/api/v2/company/' + this.companyId + '/settings/api_key';
        this.$http.get(url).then(resp => {
         this.keys = resp.data.keys
        });
      }
  },
  computed: {
    postmarkUrl() {
      return [
        "https://www.cercle.co/api/v2/company/",
        this.companyId, "/email?token= ",
        this.keys.postmarkToken, "&source=postmark"
      ].join('')
    }
  },
    mounted() {
      this.fetchKeys();
    }
  };
  </script>
<style lang="sass" scoped>
  textarea {
    width: 100%;
    height: 100px;
    word-wrap: break-word;
  }

</style>
