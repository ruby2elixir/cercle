<template>
  <div class="box">

    <div class="box-body box-profile" style="text-align:center;" v-if="!organization">
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
      
      <a href="#" class="add-organization" v-on:click="buildOrganization($event)">+Add a organization</a>
    </div>
    
    <div class="box-body box-profile" v-if="organization">
      <dropdown>
        <li><a href="#" v-on:click="removeOrganization">Remove</a></li>
      </dropdown>
      <h3 class="profile-username">
         <inline-edit v-model="organization.name" v-on:input="update" placeholder="Organization Name"></inline-edit>
      </h3>
      <ul class="list-group list-group-unbordered" style="margin-bottom:5px;">
        <li class="list-group-item" style="padding-bottom:4px;">
         <inline-edit v-model="organization.website" v-on:input="update" placeholder="WebSite"></inline-edit>
        </li>
      </ul>
      <inline-text-edit v-model="organization.description" v-on:input="update" placeholder="Note"></inline-text-edit>
    </div><!-- /.box-body -->
    
  </div><!-- /.box -->


</template>

<script>
  import InlineEdit from "../inline-common-edit.vue"
  import InlineTextEdit from "../inline-textedit.vue"
  import DropDown from "./dropdown.vue"
  export default {
      props: {
          organization: {type: Object, default: function() { return null }     }
          },
      data(){
          return {
            openModal: false,
            chooseOrganization: null,
            organizations: [],
            newOrganization: false
          }
          },
  methods: {
  saveOrganization(){
    this.$emit('choose', this.chooseOrganization)  
    this.openModal = false;

  },
    addOrganization(item) {
      this.$emit('add_new', { name: item })  
      this.openModal = false;
      return this.chooseOrganization;
    },
    removeOrganization() { this.$emit('remove') },
    buildOrganization(event) {
      event.preventDefault();
      this.$http.get('/api/v2/user/organizations', {}).then(resp => {
      this.organizations = resp.data
      this.openModal = true;      
    })
    

      
    },
    update(){ this.$emit('update', this.organization)  }
  },
  components: {
    'inline-edit': InlineEdit, 
    'inline-text-edit': InlineTextEdit,
    'dropdown': DropDown,
    'modal': VueStrap.modal,
    'v-select': vSelect.VueSelect
  }

  }
</script>

<style lang="sass">
.add-organization {
                  font-size:16px;
}
</style>
