<template>
  <div class="col-md-6">
    <!-- Profile Image -->
    <div class="box box-primary">
      <div class="box-body box-profile">
        <div class="box-tools pull-right">
          <button type="button" class="btn btn-box-tool" id="edit_contact_options" ><i class="fa fa-fw fa-angle-down"></i></button>
        </div>
        <h3 class="profile-username" style="margin-right:30px;">
           <inline-edit v-model="contact.name" v-on:input="updateContact" placeholder="Name"></inline-edit>
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
             <ul id="contact-tags">
               <li v-for="tag in tags">
                 {{ tag.name }}
               </li>
             </ul>
              <a id="add_tags" href ="javascript:void(0);" style="font-weight:bold;display:inline-block;padding:3px;border-radius:5px;margin-right:7px;color:grey;">+ Add ...</a>
            </div>
          </li>
        </ul>
        <inline-edit v-model="contact.description" v-on:input="updateContact" placeholder="Description" ></inline-edit>
      </div><!-- /.box-body -->
    </div><!-- /.box -->
  </div>
</template>

<script>
  import {Socket, Presence} from "phoenix"
  import InlineEdit from "../inline-common-edit.vue"
  export default {
  props: ['contact', 'tags'],
  methods: {
  updateContact: function(){
    this.$emit('update', this.contact)
  }
  },
    components: {
      'inline-edit': InlineEdit
    }
  }
</script>

<style lang="sass">

</style>
