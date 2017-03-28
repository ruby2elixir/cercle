<template>
  <div>
  <div class="box-tools pull-right dropdown ">
    <button type="button" class="btn btn-box-tool"  v-on:click="menuModal = !menuModal"><i class="fa fa-fw fa-angle-down"></i></button>
    <modal title="What do you want to do?"  :show.sync="menuModal">
      <div slot="modal-body" class="modal-body">
        <button type="button" class="btn btn-block btn-default" v-on:click="removeOrganization">Remove this company</button>
        <br />
        <button type="button" class="btn btn-block btn-default">Display Archived Boards</button>
        <br />
        <button type="button" class="btn btn-block btn-default">Delete this Contact</button>
      </div>

      <div slot="modal-footer" class="modal-footer"></div>
    </modal>
  </div>

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
        menuModal: false,
        openModal: false,
        chooseOrganization: null,
        organizations: [],
        newOrganization: false
      };
    },
    methods: {
      saveOrganization(){
        let url = '/api/v2/contact/' + this.contact.id;
        this.$http.put(url, { contact: { organizationId: this.chooseOrganization.id }});
        this.openModal = false;
      },

      addOrganization(item) {
        let vm = this;
        let url = '/api/v2/organizations';
        this.$http.post(url, { organization: { name: item, companyId: vm.company.id }}).then(resp => {
          this.getOrganizations(function(r){
            vm.organizations = r.data;
            vm.chooseOrganization = resp.data.data;
          });

        });
        return this.chooseOrganization;
      },
      removeOrganization() {
        this.menuModal = false;
        let url = '/api/v2/contact/' + this.contact.id;
        this.$http.put(url, { contact: {organizationId: '' }});
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
        let vm = this;
        let url = '/api/v2/organizations/' + this.organization.id;
        this.$http.put(url, {
          contactId: this.contact.id,
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
