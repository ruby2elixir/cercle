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
           <v-select multiple
             v-model.sync="tags"
             label="name"
             :on-search="getTags"
             :options="availableTags"
             :pushTags="true"
             :taggable='true'
             :createOption='addTag'
             v-on:search:focus = "getTags"
             :placeholder="Tags"></v-select>
            </div>
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
    props: ['contact', 'tags'],
    data(){
    return {
     availableTags: null
    }
    },
    mounted(){

    },
     watch: {
            tags: function(){
                  this.updateTags($.map(this.tags, function(tag){ return tag.id }))
      }           
     },
    methods: {
    
        getTags() {
          if (this.availableTags === null) {
            this.$http.get('/api/v2/tags', {
              params: { company_id: this.contact.company_id }
            }).then(resp => {
              this.availableTags = resp.data
            })
         }
        },
        addTag(tag) {
          return { id: tag, name: tag }
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
        'v-select': vSelect.VueSelect
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
