<template>
  <div class="box" id="without_organization" style="display:;">
    <div class="box-body box-profile" style="text-align:center;">
      <a href="#sd" style="font-size:16px;" id="change_company_modal">+Add a company</a>
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
