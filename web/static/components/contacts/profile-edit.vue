<template>
  <div class="col-md-6">
    <!-- Profile Image -->
    <div class="box box-primary">
      <div class="box-body box-profile">
        <dropdown>
            <li><a href="#" v-on:click="deleteContact">Remove</a></li>
        </dropdown>

        <h3 class="profile-username" style="margin-right:30px;">
          <inline-edit v-model.lazy="contact.name" v-on:input="updateContact" placeholder="Name"></inline-edit>
        </h3>

        <ul class="list-group list-group-unbordered" style="margin-bottom:5px;">
          <li class="list-group-item" style="padding-bottom:4px;">
            <inline-edit v-model="contact.job_title" v-on:input="updateContact"  placeholder="Job Title" ></inline-edit>
          </li>
          <li class="list-group-item" style="padding-bottom:4px;">
            <inline-edit v-model="contact.email" v-on:input="updateContact"  placeholder="Email" ></inline-edit>
          </li>
          <li class="list-group-item" style="padding-bottom:4px;">
            <inline-edit v-model="contact.phone" v-on:input="updateContact" placeholder="Phone"></inline-edit>
          </li>
          <li class="list-group-item" style="padding-bottom:4px;">
           
           <div class="contact-tags-box">
             <button type="button" class="btn btn-box-tool btn-default btn-sm" v-for="(tag, index) in tags" style="margin: 2px;" v-on:click="removeTag(index);">
               {{tag.name}}
               <i class="fa fa-fw fa-close"></i>
             </button>
             <button type="button" class="btn btn-link" v-on:click="openTagsWindow()">
               <i class="fa fa-fw fa-plus"></i>Add
             </button>
          </div>
          <modal title="Tags" large :show.sync="openTagModal">
            <div slot="modal-body" class="modal-body">
            <v-select
              multiple
              label="name"
              v-model="chooseTags"
              :options="availableTags" 
              :pushTags="true"
              :taggable="true"
              :placeholder="Tags"
              :createOption='addNewTag'
             ></v-select>
            </div>
            <div slot="modal-footer" class="modal-footer">
             <button type="button" class="btn btn-success" v-on:click="saveChangesTag" >Save changes</button>
            </div>
          </modal>
      
          </li>
        </ul>
        <inline-text-edit v-model="contact.description" v-on:input="updateContact" placeholder="Description" ></inline-text-edit>
      </div><!-- /.box-body -->
    </div><!-- /.box -->
  </div>
</template>

<script>
Vue.use(VueResource);
import {Socket, Presence} from "phoenix"

import InlineEdit from "../inline-common-edit.vue"
import InlineTextEdit from "../inline-textedit.vue"
import DropDown from "./dropdown.vue"

export default {
    props: [
    'contact',
    'tags'
    ],
    data(){
      return {
        availableTags: [],
        openTagModal: false,
        chooseTags: []
     }
    },
    mounted(){

    },
     watch: {

     },
    methods: {
        removeTag(index) {
          this.tags.splice(index, 1);
          this.tag_ids = this.tags.map(function(j) { return j.id })
          this.$emit('updateTags', this.tag_ids)
        },
        addNewTag(input){
          return { id: input, name: input }
        },
        saveChangesTag(){
          this.tag_ids = this.chooseTags.map(function(j) { return j.id })
          this.tags = this.chooseTags.map(function(j) { return {id: j.id, name: j.name }  })
          this.$emit('updateTags', this.tag_ids)
          this.openTagModal = false;
        },
        openTagsWindow(){
        
          this.chooseTags = this.tags.map(function(j) { return {id: j.id, name: j.name } })
          this.getTags() 
          this.openTagModal = true;
        },
        getTags() {
          this.$http.get('/api/v2/tags', {
            params: { company_id: this.contact.company_id }
           }).then(resp => {
             this.availableTags = resp.data
          })
        },

        deleteContact: function(){
         console.log('delete contact');
        },
        updateTags: function(data){
            this.$emit('updateTags', data)
        },
        updateContact: function(){
            this.$emit('update', this.contact)
        }
    },
    components: {
        'inline-edit': InlineEdit,
        'inline-text-edit': InlineTextEdit,
        'dropdown': DropDown,
        'v-select': vSelect.VueSelect,
        'modal': VueStrap.modal

    }
}
</script>

<style lang="sass">
    .contact-tags-box {
    .open-indicator{
    display: none !important; 
    }
            .selectize-control {
                border: none;
                box-shadow: none;
                    .selectize-input{
                        border: none;
                        box-shadow: none;
                            .item {
                                background-image: none !important;
                            }
                    }
            }
    }
</style>
