<template>
  <div class="col-md-12">
    <div class="post" style="background-color:white;box-shadow: 0 1px 1px rgba(0,0,0,0.1);border-radius: 3px;">
      <!-- /.user-block -->
      <div style="padding:15px;">
        <form id="contact-form" >

          <h3 style="margin-top:0px;border-bottom:0px solid #d8d8d8;">
            <i class="fa fa-fw fa-check-square-o" style="color:#d8d8d8;"></i> To-Do
          </h3>
          <div id="tasks" style="padding:15px;">

          </div>
          <div style="padding-left:15px;">
            <a style="letter-spacing: 1px;color:grey;font-weight:bold;" id="activity_add" href="javascript:void(0);" >Schedule a  Task...</a>
          </div>
          <Br />
          <Br />

          <h3 style="margin-top:0px;border-bottom:0px solid #d8d8d8;">
            <i class="fa fa-fw fa-comments-o" style="color:#d8d8d8;"></i>
            Comment
          </h3>
          <input type="hidden" name="timeline_event[event_name]" value="comment">
          <Br />
          <div style="margin-bottom:0px;">
            <img class="img-circle img-bordered-sm" src="" alt="user image" style="width:40px;float:left;">
            <div style="margin-left:50px;margin-right:10px;">
              <textarea class="form-control" name="timeline_event[content]" id="inputExperience" placeholder="Write a comment.."  style="height:70px;"></textarea>
              <br />
              <input type="submit" value='Send' class="btn btn-primary" id="submit_timeline_event" />
            </div>
          </div>

        </form>
      </div>
    </div>
    <div id="timeline_events">
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
