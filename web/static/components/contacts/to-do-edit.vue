<template>
  <div style="margin-top:20px;">
    <!-- /.user-block -->
    <div>
      <h3 style="margin-top:0px;border-bottom:0px solid #d8d8d8;">
        <i class="fa fa-fw fa-check-square-o" style="color:#d8d8d8;"></i> To-Do
      </h3>
      <div id="tasks" style="padding:15px;">

      </div>
      <div style="padding-left:15px;">
        <a style="letter-spacing: 1px;color:grey;font-weight:bold;" id="activity_add" href="javascript:void(0);" >Schedule a  Task...</a>
      </div>
      <br />
      <br />
      <slot name="comment-form"></slot>
    </div>
    <div class="row">
      <div class="col-md-12">
        <br/><br/>
        <slot name="timeline-events"></slot>
      </div>
    </div>

  </div><!-- /.col -->
</template>

<script>
  import InlineEdit from "../inline-common-edit.vue"
  export default {
  props: [],
  methods: {
  },
  components: { 'inline-edit': InlineEdit  }
  }
</script>

<style lang="sass">

</style>
