<template>
  <div class="col-md-12">

    <div class="post" style="background-color:white;box-shadow: 0 1px 1px rgba(0,0,0,0.1);border-radius: 3px;padding:20px;margin-bottom:10px;">
      <button type="button" class="btn btn-default pull-right" style="margin-top:10px;margin-right:10px;" id="opportunity_win" >ARCHIVE</button>

      <div style="" id="change_status">
        <span style="font-size:24px;color:rgb(150,150,150);"> <i class="fa fa-rocket" style="color:#d8d8d8;"></i>
          <span data-placeholder="Project Name" style="color:rgb(102,102,102);">
            <inline-edit v-model.lazy="opportunity.name" v-on:input="updateOpportunity" placeholder="Project Name"></inline-edit>
          </span>
        </span>
        <Br />
        <Br />
        <div style="margin-right:20px;margin-bottom:10px;">
          Managed by:
          <select v-model="opportunity.user_id"  v-on:change="updateOpportunity">
            <option v-for="user in company_users" :value="user.id">{{user.user_name}}</option>
          </select>
          &nbsp;&nbsp;
          Status:
          <select  v-model="opportunity.board_column_id" v-on:change="updateOpportunity">
            <option v-for="board_column in board_columns" :value="board_column.id">{{board_column.name}}</option>
          </select>
        </div>
        Contacts Involved:
        <a v-for="o_contact in opportunity_contacts" :href="'/contact/'+o_contact.id" class="o_contact">{{o_contact.name}}</a>


        <a class="add_o_contact" style="font-weight:bold;display:inline-block;padding:3px;border-radius:5px;margin-right:7px;color:grey;">+ Add ...</a>

            <div style="margin-top:10px;margin-bottom:10px;">
              Description
              <br />
              <div style="margin-top:10px;" data-placeholder="Write a description...">
                <inline-text-edit v-model="opportunity.description" v-on:input="updateOpportunity" placeholder="Write a description..." ></inline-text-edit>
              </div>
            </div>
      </div>


      <to-do>
        <comment_form slot="comment-form" v-on:submit="addComment" />
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
  import InlineTextEdit from "../inline-textedit.vue"

  export default {
  props: [
    'activities', 'events', 'opportunity', 'company',
    'company_users', 'board',
    'board_columns', 'opportunity_contacts'
  ],
  methods: {
  addComment(msg){
  this.$emit('addComment', msg)
  },
  updateOpportunity(){
    this.$emit('updateOpportunity', this.opportunity)
  },
  },
  components: {
  'inline-edit': InlineEdit,
  'to-do': ToDo,
  'comment_form': CommentForm,
  'timeline_events': TimelineEvents,
  'inline-text-edit': InlineTextEdit,
  'v-select': vSelect.VueSelect,
  }

  }
</script>

<style lang="sass">
  a.o_contact  {
  font-weight:bold;
  display:inline-block;
  padding:3px;
  border-radius:5px;
  margin-right:7px;
  color:grey;
  text-decoration:underline;
  }
  a.add_o_contact {
  font-weight:bold;
  display:inline-block;
  padding:3px;
  border-radius:5px;
  margin-right:7px;
  color:grey;
  }
</style>
