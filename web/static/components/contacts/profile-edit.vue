<template>
    <div class="">
      <div class="">

        <h3 class="profile-username" style="margin-right:30px;line-height: 30px;height: 30px;font-size:24px;">
          <i class="fa fa-user" style="color:#d8d8d8;"></i>
          
          <inline-edit v-model.lazy="contact.name" v-on:input="updateContact" placeholder="Name"></inline-edit>
        </h3>
            <div>
              <inline-edit v-model="contact.job_title" v-on:input="updateContact"  placeholder="Job Title" ></inline-edit>
            </div>
            <div>
            <inline-edit v-model="contact.email" v-on:input="updateContact"  placeholder="Email" ></inline-edit>
            </div>
            <div>
            <inline-edit v-model="contact.phone" v-on:input="updateContact" placeholder="Phone"></inline-edit>
            </div>
          <div class="" style="padding-bottom:4px;">
           
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
      
          </div>
        <inline-text-edit v-model="contact.description" v-on:input="updateContact" placeholder="Description" ></inline-text-edit>
      </div><!-- /.box-body -->
    </div><!-- /.box -->

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
          this.$http.post('/api/v2/tag', {
            tags: { name: input }, company_id: this.contact.company_id 
           }).then(resp => {
          })
          
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
          this.$http.get('/api/v2/tag', {
            params: { company_id: this.contact.company_id }
           }).then(resp => {
             this.availableTags = resp.data
          })
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
    }
</style>
