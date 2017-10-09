<template>
  <div class="contact-attributes">
    <div class="row">
      <div class="col-lg-4">
        <label>Name</label>
        <br />
        <span class="attribute-value">
          <name-input-modal :first-name="contact.firstName"
                            :last-name="contact.lastName"
                            v-on:input="contactNameInput"/>
        </span>
      </div>

      <div class="col-lg-4">
        <label>Title</label>
        <br />
        <span class="attribute-value">
          <input-modal v-model="contact.jobTitle"
                       v-on:input="updateContact"
                       placeholder="Click to add" label="Title" />
        </span>
      </div>

      <div class="col-lg-4">
        <label>Phone number</label>
        <br />
        <span class="attribute-value">
          <input-modal v-model="contact.phone"
                       v-on:input="updateContact"
                       placeholder="Click to add" label="Phone" />
        </span>
      </div>

      <div class="col-lg-4">
        <label>Email</label>
        <br />
        <span class="attribute-value">
          <input-modal v-model="contact.email"
                       v-on:input="updateContact"
                       placeholder="Click to add" label="Email" />
        </span>
      </div>

      <div class="col-lg-4">
        <label>Company</label>
        <br />
        <span class="attribute-value organization-name">
          <organization-select :organization="contact.organization" @change="changeOrganization">
            <input-modal v-model="contact.organization.name" v-on:input="updateOrganization"  placeholder="Click to add" label="Company name" v-if="contact.organization" />
            <a @click="removeOrganization" class="remove-organization">×</a>
          </organization-select>
        </span>
      </div>

      <div class="col-lg-4" v-if="contact.organization">
        <label>Company website</label>
        <br />
        <span class="attribute-value organization-website">
          <input-modal v-model="contact.organization.website" v-on:input="updateOrganization"  placeholder="Click to add" label="Website" />
        </span>
      </div>
    </div>

    <div class="row">
      <div class="contact-description col-lg-12">
        <markdown-text-edit v-model="contact.description"
                            v-on:input="updateContact"
                            placeholder="Write a description" >
        </markdown-text-edit>
      </div>
    </div>
  </div>
</template>

<script>
  import inputModal from '../shared/input-modal.vue';
  import nameInputModal from '../shared/name-input-modal.vue';
  import MarkdownTextEdit from '../shared/markdown-textedit.vue';
  import OrganizationSelect from '../shared/organization-select.vue';

  export default {
    props: ['contact'],
    data() {
      return {};
    },
    components: {
      'name-input-modal': nameInputModal,
      'input-modal': inputModal,
      'markdown-text-edit': MarkdownTextEdit,
      'organization-select': OrganizationSelect
    },
    methods: {
      contactNameInput: function(data) {
        this.contact.firstName = data.firstName;
        this.contact.lastName = data.lastName;
        this.updateContact();
      },
      updateContact() {
        let url = '/api/v2/company/'+ Vue.currentUser.companyId +'/contact/' + this.contact.id;
        this.$http.put(url, { contact: this.contact } );
      },
      changeOrganization(organization) {
        this.contact.organization = organization;
        let url = '/api/v2/company/'+ Vue.currentUser.companyId +'/contact/' + this.contact.id;
        this.$http.put(url, { contact: { organizationId: organization.id }});
      },
      removeOrganization() {
        this.contact.organization = null;
        let url = '/api/v2/company/'+ Vue.currentUser.companyId +'/contact/' + this.contact.id;
        this.$http.put(url, { contact: { organizationId: '' }});
      },
      updateOrganization() {
        let vm = this;
        let url = '/api/v2/company/'+ Vue.currentUser.companyId +'/organizations/' + this.contact.organization.id;
        this.$http.put(url, {
          contactId: this.contact.id,
          organization: this.contact.organization
        });
      }
    }
  };
</script>

<style lang="sass" scoped>
  .contact-attributes {
    margin-top: 10px;

    .attribute-value {
       margin-right:7px;
       border-radius: 5px;
       display:inline-block;
       padding: 0 3px;
       background-color: lightgray;
    }

    .contact-attributes {
      margin-bottom: 10px;
    }

    .contact-description {
      min-height: 100px;
    }

    .contact-description {
      margin-top: 10px;
    }

    .remove-organization {
      cursor: pointer;
      font-weight: bold;
      color: #333;
    }
  }
</style>
