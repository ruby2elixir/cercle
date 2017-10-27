<template>
  <div class="contact-show">
    <div class="row">
      <div class="col-md-12">
        <contact-details :contact="contact" />
      </div>
    </div>

    <div class="row" v-if="emails.length">
      <div class="col-md-12">
        <h4>Emails</h4>
        <table class="table table-striped">
          <tbody>
            <tr v-for="email in emails" @click="showEmail(email)">
              <td :title="email.fromEmail">{{ email.fromEmail | truncate(25) }}</td>
              <td>{{ email.subject }}</td>
              <td>{{ renderText(email.body) }}</td>
              <td>{{ email.date|formatDateTime }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import ContactDetails from './contact-details.vue';

export default {
  props: ['contact'],
  data() {
    return {
      emails: []
    };
  },
  components: {
    'contact-details': ContactDetails
  },
  watch: {
    contact() {
      this.fetchEmails();
    }
  },
  methods: {
    renderText(html) {
      return '';
    },

    fetchEmails() {
      if(this.contact.email) {
        let url = '/api/v2/company/' + Vue.currentUser.companyId + '/email?email=' + this.contact.email;
        this.$http.get(url).then(resp => {
          this.emails = resp.data.data;
        });
      } else {
        this.emails = [];
      }
    },

    showEmail(email) {
      this.$glmodal.$emit(
        'open',
        {
          view: 'email-show', class: 'email-modal',
          data: { 'email': email }
        }
      );
    }
  },
  mounted() {
    this.fetchEmails();
  }
};
</script>

<style>
  .contact-show {
    padding: 20px;
  }
</style>
