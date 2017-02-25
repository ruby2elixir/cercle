<template>
  <div class="box" id="with_organization" style="display:;">
    <div class="box-body box-profile">
      <div class="box-tools pull-right">
        <button type="button" class="btn btn-box-tool" id="edit_contact_options" ><i class="fa fa-fw fa-angle-down"></i></button>
      </div>
      <h3 class="profile-username">

        <span class='inline-editable' data-type='PUT' data-param-name="organization[name]" data-inline-editurl="/api/v2/organizations/">ORGANIZATION NAME</span>
      </h3>
      <ul class="list-group list-group-unbordered" style="margin-bottom:5px;">
        <li class="list-group-item" style="padding-bottom:4px;">
          <input type="text" placeholder="Website" style="border:0px solid grey;width:100%;line-height:30px;" />
        </li>
      </ul>
      <input type="text" placeholder="Note" style="border:0px solid grey;width:100%;line-height:30px;" />

    </div><!-- /.box-body -->
  </div><!-- /.box -->


</template>

<script>
  import InlineEdit from "../inline-common-edit.vue"
  export default {
  props: ['company'],
  methods: {
  update: function(){  this.$emit('update', this.company)  }
  },
  components: { 'inline-edit': InlineEdit  }
  }
</script>

<style lang="sass">

</style>
