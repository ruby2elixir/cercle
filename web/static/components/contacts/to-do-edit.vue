<template>
  <div class="contact-to-dos">
    <div>
      <h3 style="margin-top:0px;border-bottom:0px solid #d8d8d8;">
        <i class="fa fa-fw fa-check-square-o" style="color:#d8d8d8;"></i> To-Do
      </h3>
      <div style="padding:15px;">
        <div  v-for="task in tasks" class="task row">
          <div class="col-md-1">
            <input type="checkbox" v-model.sync="task.is_done" class="task-is-done" v-on:click="updateTask(task)">
          </div>
          <div class="col-md-5">
            <inline-edit v-model.sync="task.title" v-on:input="updateTask(task)" placeholder="Title" class="title-input"></inline-edit>
          </div>
          <div class="col-md-2">
            <span>{{ task.due_date | moment("MM/DD/YYYY") }}</span>
          </div>
          <div class="col-md-2">
            <span>{{ task.due_date | moment("HH:mm") }}</span>
          </div>

          <div class="col-md-1">
            <select v-model="task.user_id">
              <option v-for="user in company_users" :value="user.id">{{(user.user_name.toUpperCase()).slice(0, 2)}}</option>
            </select>
          </div>

          <div class="col-md-1 remove-task">
            <button class="btn btn-link" v-on:click="removeTask(task)"> <i class="fa fa-fw fa-close"></i></button>
          </div>
        </div>


      </div>
      <div class="add-to-do">
        <button  class="btn btn-link" v-on:click="addTask">Schedule a  Task...</button>
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

  </div>
</template>

<script>
  import InlineEdit from "../inline-common-edit.vue"
  export default {
      props: {
          time_zone: String,
          current_user_id: String,
          activities: { type: Array, default: [] },
          company_users: { type: Array, default: [] },
          contact: Object,
          opportunity: Object,
          company: Object
      },
      computed: {

      },
      data() {
          return {
              tasks: this.activities
          }
  },
  methods: {
      addTask() {
          var url = '/api/v2/activity/';
          this.$http.post(url, {
              activity: {
                  contact_id: this.contact.id,
                  opportunity_id: this.opportunity.id,
                  user_id: this.current_user_id,
                  due_date: new Date().toISOString(),
                  company_id: this.company.id,
                  title: 'Call',
                  current_user_time_zone: this.time_zone
              } })
      },
      removeTask(task) {
          var url = '/api/v2/activity/' + task.id;
          this.$http.delete(url)
          false;
      },
      updateTask(task) {
          var url = '/api/v2/activity/' + task.id;
          this.$http.put(url, {
              activity: {
                  title: task.title,
                  contact_id: this.contact.id,
                  opportunity_id: this.opportunity.id,
                  user_id: this.current_user_id,
                  company_id: this.company.id
              }
          })
      }
  },
  components: {
  'inline-edit': InlineEdit,
  'checkbox': VueStrap.checkbox
  }
  }
</script>

<style lang="sass">
  .contact-to-dos {
  .add-to-do {
  padding-left:15px;
  button {
    letter-spacing: 1px;
    color:grey;
    font-weight:bold;
  }
  }
  .remove-task {
  font-size:10px;line-height:30px;text-align:right;
  button {
      font-size: 7.9pt;
  i {
  color:#cacaca;
  }
  }
  }
  .title-input {
  width: 100%;
  }
  .task-is-done {
  border: 0px solid grey;
  }
  }
</style>
