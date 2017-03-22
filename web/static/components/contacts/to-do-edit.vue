<template>
  <div class="contact-to-dos">
    <div>
      <h3>
        <i class="fa fa-fw fa-check-square-o" style="color:#d8d8d8;"></i> To-Do
      </h3>
      <div style="padding:15px;">
        <div  v-for="task in tasks" class="task row">
          <div class="col-md-1 task-is-done">
    <input type="checkbox" :id="'task-' + task.id" v-model.sync="task.is_done" :class="{'active': task.is_done}" v-on:click="updateTask(task)">
    <label :for="'task-'+task.id"></label>
          </div>
          <div class="col-md-5">
            <inline-edit v-model.sync="task.title" v-on:input="updateTask(task)" placeholder="Title" class="title-input"></inline-edit>
          </div>
          <div class="col-md-2">
            <inline-edit v-model.sync="task.due_only_date" v-on:input="updateTask(task)" placeholder="Time" class="title-input"></inline-edit>
          </div>
          <div class="col-md-2">
            <inline-edit v-model.sync="task.due_time" v-on:input="updateTask(task)" placeholder="Time" class="title-input"></inline-edit>
          </div>

          <div class="col-md-1">
            <select v-model="task.user_id">
              <option v-for="user in companyUsers" :value="user.id">{{(user.user_name.toUpperCase()).slice(0, 2)}}</option>
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
  import InlineEdit from '../inline-common-edit.vue';
  export default {
    props: {
      timeZone: String,
      currentUserId: String,
      activities: { type: Array, default: [] },
      companyUsers: { type: Array, default: [] },
      contact: Object,
      opportunity: Object,
      company: Object
    },
    computed: {

    },
    data() {
      return {
        tasks: this.activities.map(function(item){
          item.due_time = Vue.moment(item.due_date).format('HH:mm');
          item.due_only_date = Vue.moment(item.due_date).format('MM/DD/YYYY');
          return item;
        }
              )
      };
    },
    methods: {
      addTask() {
        var url = '/api/v2/activity/';
        this.$http.post(url, {
          activity: {
            contact_id: this.contact.id,
            opportunity_id: this.opportunity.id,
            user_id: this.currentUserId,
            due_date: new Date().toISOString(),
            company_id: this.company.id,
            title: 'Call',
            current_user_time_zone: this.timeZone
          } });
      },
      removeTask(task) {
        var url = '/api/v2/activity/' + task.id;
        this.$http.delete(url);
        false;
      },
      updateTask(task) {
        var url = '/api/v2/activity/' + task.id;
        var due_date = new Date(task.due_only_date + ' ' + task.due_time);

        this.$http.put(url, {
          activity: {
            title: task.title,
            due_date: Vue.moment(due_date).toISOString(),
            contact_id: this.contact.id,
            opportunity_id: this.opportunity.id,
            user_id: this.currentUserId,
            company_id: this.company.id,
            is_done: task.is_done
          }
        });
      }
    },
    components: {
      'inline-edit': InlineEdit,
      'checkbox': VueStrap.checkbox
    }
  };
</script>

<style lang="sass">
.contact-to-dos {
  h3 {
    margin-top:0px;
    border-bottom:0px solid #d8d8d8;
  }
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
  .task-time {
  .time-picker {
  max-width: 100px;
  input {
  max-width: 100px;
  }
  .dropdown {
  max-width: 100px;
  .select-list {
  max-width: 100px;
  }
  }
  }
  }
  .task-is-done {
      border: 0px solid grey;

      /*** custom checkboxes ***/
      label { margin-top: -5px; }
      input[type=checkbox] { display:none; } /* to hide the checkbox itself */
      input[type=checkbox] + label:before {
          font-family: FontAwesome;
          display: inline-block;
          font-size: 24px;
              -webkit-text-stroke: 2px white;
      }

      input[type=checkbox] + label:before { content: "\f096"; } /* unchecked icon */
      input[type=checkbox] + label:before { letter-spacing: 10px; } /* space between checkbox and label */

      input[type=checkbox]:checked + label:before { content: "\f046"; } /* checked icon */
      input[type=checkbox]:checked + label:before { letter-spacing: 5px; } /* allow space for check mark */
  }
  }
</style>
