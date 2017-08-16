<template>
  <div class="contact-show">
    <div class="row">
      <div class="col-md-12">
        <table style="width:100%;background-color: #edf0f5;">
          <tr>
            <td style="width:50%;padding:20px;vertical-align: top;padding-right:0px;">
              <profile-edit
                :contact="contact"
                :tags="contact.tags"
                v-on:updateTags="updateTags"
                />
              <delete-contact :contact="contact"></delete-contact>
            </td>

            <td style="width:50%;padding:20px;vertical-align: top;">
              <organization-edit
                :organization="contact.organization"
                :contact="contact"
                :companyId="contact.companyId"
                v-on:updateOrganization="updateOrganization"
                >
               </organization-edit>
            </td>
          </tr>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import ProfileEdit from './profile-edit.vue';
import OrganizationEdit from './organization-edit.vue';
import DeleteContact from './delete.vue';

export default {
  props: ['contact'],
  data() {
    return {
    };
  },
  watch: {
  },
  components: {
    'profile-edit': ProfileEdit,
    'organization-edit': OrganizationEdit,
    'delete-contact': DeleteContact
  },
  methods: {
    updateOrganization(org) {
      this.contact.organization = org;
    },
    updateTags(selectedTags) {
      this.contact.tags = selectedTags;
    }
  },
  mounted(){
  }

};
</script>
