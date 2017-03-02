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
             <v-selectize :selected="tags" v-on:input="updateTags" ></v-selectize>
            </div>
          </li>
        </ul>
        <inline-text-edit v-model="contact.description" v-on:input="updateContact" placeholder="Description" ></inline-text-edit>
      </div><!-- /.box-body -->
    </div><!-- /.box -->
  </div>
</template>

<script>
import {Socket, Presence} from "phoenix"

import InlineEdit from "../inline-common-edit.vue"
import InlineTextEdit from "../inline-textedit.vue"
import vSelectize from "../vue-selectize.vue"
import DropDown from "./dropdown.vue"
export default {
    props: ['contact', 'tags'],
    methods: {
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
        'v-selectize': vSelectize,
        'dropdown': DropDown
    }
}
</script>

<style lang="sass">
    .contact-tags-box {
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
