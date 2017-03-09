<template>
<div class="col-md-12">
  <div class="post" style="background-color:white;box-shadow: 0 1px 1px rgba(0,0,0,0.1);border-radius: 3px;padding:20px;margin-bottom:10px;">
    <button type="button" class="btn btn-default pull-right" style="margin-top:10px;margin-right:10px;" id="opportunity_win" >ARCHIVE</button>

    <div style="" id="change_status">
      <span style="font-size:24px;color:rgb(150,150,150);"> <i class="fa fa-rocket" style="color:#d8d8d8;"></i> 
        <span style="color:rgb(102,102,102);" class='inline-editable' data-type='PUT' data-param-name="opportunity[name]" data-inline-editurl="/api/v2/opportunity/">OPPOR NAME</span>
      </span>
      <Br />
      <Br />
      <div style="margin-right:20px;margin-bottom:10px;">
        Managed by:
      </div>
      Status:
      <Br />
      <Br />
      Contacts Involved:
      <a id="add_contact_to_opportunity" href ="javascript:void(0);" style="font-weight:bold;display:inline-block;padding:3px;border-radius:5px;margin-right:7px;color:grey;">+ Add ...</a>
    </div>
    
    <to-do>
      <comment_form slot="comment-form" />
      <timeline_events
        slot="timeline-events"
        :events="events"
        /> 
    </to-do>
    
  </div>
</div>

</template>

<script>
  import InlineEdit from "../inline-common-edit.vue"
  import ToDo from "./to-do-edit.vue"
  import CommentForm from "./comment-form.vue"
  import TimelineEvents from "./timeline-events.vue"
  export default {
  props: ['activities', 'events'],
  methods: {

  },
  components: { 
    'inline-edit': InlineEdit,
    'to-do': ToDo,
    'comment_form': CommentForm,
    'timeline_events': TimelineEvents
  }
  }
</script>

<style lang="sass">

</style>
