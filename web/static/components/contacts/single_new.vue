<template>
  <div>
    <div class='referral-container'>
      <div class='referral-header'>
        <div class='company-title'>
          <h1>New Contact</h1>
        </div>
      </div>

      <div class='referral-form-container' style="min-height:800px;">
        <div class='referral-form-header'>
          <div class='line2'></div>
        </div>

        <div class='referral-form-content'>
          <div class='referral-form-title'>Please, enter below</div>
          <br />
          <div class='referral-form-body'>
            <input v-model="firstName"
                   type='text' placeholder='First Name'
                   class='form-control user_name'
                   style="max-width:300px;margin-bottom:10px;"/>
            <input v-model="lastName" type='text'
                   placeholder='Last Name' class='form-control user_name'
                   style="max-width:300px;margin-bottom:10px;"/>
            <input v-model="email" type='text' placeholder='Email'
                   class='form-control email'
                   style="max-width:300px;margin-bottom:10px;" />
            <input v-model="phone" type='text'
                   placeholder='Phone' class='form-control phone'
                   style="max-width:300px;margin-bottom:10px;" />
          </div>
          <br />
          <div class='referral-form-footer'>
            <button class="btn btn-primary" @click="saveContact">Create</button>
          </div>

        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    props: ['companyId'],
    data: function() {
      return {
        firstName: null,
        lastName: null,
        email: null,
        phone: null

      };
    },
    components: {
      'v-select': vSelect.VueSelect
    },
    methods: {
      saveContact(){
        let url = '/api/v2/company/'+ Vue.currentUser.companyId +'/contact';
        let contactsUrl = '/company/'+ Vue.currentUser.companyId +'/contact';
        this.$http.post(url,{
          contact: {
            companyId: this.companyId,
            firstName: this.firstName,
            lastName: this.lastName,
            email: this.email,
            phone: this.phone
          }
        }).then(resp => { this.$router.push(contactsUrl);});
      }
    },
    mounted: function() {

    }
  };
</script>
