<template>
  <div class="">
    <dropdown>
      <li><a href="#" v-on:click="removeOrganization">Remove Organization</a></li>
      <slot name="menu"></slot>
    </dropdown>

    <div class="" style="" v-if="!organization">
      <modal title="Where is the contact working currently?" large :show.sync="openModal">
        <div slot="modal-body" class="modal-body">

          <v-select
            label="name"
            v-model="chooseOrganization"
            :options="organizations"

            :pushTags="true"
            :taggable="true"
            :placeholder="Organization"
            :createOption='addOrganization'
            ></v-select>
        </div>
        <div slot="modal-footer" class="modal-footer">
          <button type="button" class="btn btn-success" v-on:click="saveOrganization">Save changes</button>
        </div>
      </modal>
      <br />
      <br />
      <a href="#" class="add-organization" v-on:click="buildOrganization($event)">+Add a organization</a>
    </div>

    <div class="box-body box-profile" v-if="organization">

      <br /><br />
      <div>
        Working at <inline-edit v-model="organization.name" v-on:input="update" placeholder="Organization Name"></inline-edit>
      </div>
      <inline-edit v-model="organization.website" v-on:input="update" placeholder="WebSite"></inline-edit>
      <inline-text-edit v-model="organization.description" v-on:input="update" placeholder="Note about the organization"></inline-text-edit>
    </div><!-- /.box-body -->

  </div><!-- /.box -->


</template>

<script>
  import InlineEdit from '../inline-common-edit.vue';
  import InlineTextEdit from '../inline-textedit.vue';
  import DropDown from './dropdown.vue';
  export default {
    props: {
      organization: {type: Object, default: function() { return null; } },
      contact: Object,
      company: Object
    },
    data(){
      return {
        openModal: false,
        chooseOrganization: null,
        organizations: [],
        newOrganization: false
      };
    },
    methods: {
      saveOrganization(){
        var url = '/api/v2/contact/' + this.contact.id;
        this.$http.put(url, { contact: { organization_id: this.chooseOrganization.id }});
        this.openModal = false;
      },

      addOrganization(item) {
        var vm = this;
        var url = '/api/v2/organizations';
        this.$http.post(url, { organization: { name: item, company_id: vm.company.id }}).then(resp => {
          this.getOrganizations(function(r){
            vm.organizations = r.data;
            vm.chooseOrganization = resp.data.data;
          });

        });
        return this.chooseOrganization;
      },
      removeOrganization() {
        var url = '/api/v2/contact/' + this.contact.id;
        this.$http.put(url, { contact: {organization_id: '' }});
      },
      buildOrganization(event) {
        event.preventDefault();
        this.$http.get('/api/v2/user/organizations', {}).then(resp => {
          this.organizations = resp.data;
          this.openModal = true;
        });
      },
      getOrganizations(callback) {
        this.$http.get('/api/v2/user/organizations', {}).then(resp => {
          callback(resp);
        });
      },
      update(){
        var vm = this;
        var url = '/api/v2/organizations/' + this.organization.id;
        this.$http.put(url, {
          contact_id: this.contact.id,
          organization: this.organization
        });
      }
    },
    components: {
      'inline-edit': InlineEdit,
      'inline-text-edit': InlineTextEdit,
      'dropdown': DropDown,
      'modal': VueStrap.modal,
      'v-select': vSelect.VueSelect
    }

  };
</script>
