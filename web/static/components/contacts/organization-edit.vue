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
      organization: {type: Object, default: function() { return null; }     }
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
        this.$emit('choose', this.chooseOrganization);
        this.openModal = false;

      },
      addOrganization(item) {
        this.$emit('add_new', { name: item });
        this.openModal = false;
        return this.chooseOrganization;
      },
      removeOrganization() { this.$emit('remove'); },
      buildOrganization(event) {
        event.preventDefault();
        this.$http.get('/api/v2/user/organizations', {}).then(resp => {
          this.organizations = resp.data;
          this.openModal = true;
        });



      },
      update(){ this.$emit('update', this.organization);  }
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

<style lang="sass">
.add-organization {
                  font-size:16px;
}
</style>
