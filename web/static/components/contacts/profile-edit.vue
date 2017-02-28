<template>
  <div class="col-md-6">
    <!-- Profile Image -->
    <div class="box box-primary">
      <div class="box-body box-profile">
        <div class="box-tools pull-right">
          <button type="button" class="btn btn-box-tool" id="edit_contact_options" ><i class="fa fa-fw fa-angle-down"></i></button>
        </div>
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
    <div style="margin-top:5px;">

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
export default {
    props: ['contact', 'tags'],
    data() {
        return {

        }
    },
    methods: {

        updateContact: function(){
            this.$emit('update', this.contact)
        }
    },
    components: {
        'inline-edit': InlineEdit,
        'inline-text-edit': InlineTextEdit
    }
}
</script>

<style lang="sass">

</style>
