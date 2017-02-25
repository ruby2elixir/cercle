<template>
  <div class="box" id="with_organization" style="display:;">
    <div class="box-body box-profile">
      <div class="box-tools pull-right">
        <button type="button" class="btn btn-box-tool" id="edit_contact_options" ><i class="fa fa-fw fa-angle-down"></i></button>
      </div>
      <h3 class="profile-username">
         <inline-edit v-model="organization.name" v-on:input="update" placeholder="Organization Name"></inline-edit>
      </h3>
      <ul class="list-group list-group-unbordered" style="margin-bottom:5px;">
        <li class="list-group-item" style="padding-bottom:4px;">
         <inline-edit v-model="organization.website" v-on:input="update" placeholder="WebSite"></inline-edit>
        </li>
      </ul>
      <inline-edit v-model="organization.description" v-on:input="update" placeholder="Note"></inline-edit>
    </div><!-- /.box-body -->
  </div><!-- /.box -->


</template>

<script>
  import InlineEdit from "../inline-common-edit.vue"
  export default {
      props: {
          organization: {type: Object, default: function() { return {} }     } },
  methods: {
  update: function(){  this.$emit('update', this.organization)  }
  },
  components: { 'inline-edit': InlineEdit  }

  }
</script>

<style lang="sass">

</style>
