<template>
  <div class="contact-to-dos">
    <div>
      <h3 style="color:rgb(99,99,99);font-weight:bold;">
        <i class="fa fa-fw fa-check-square-o" style="color:#d8d8d8;"></i>Tasks
      </h3>
      <div style="padding:15px;">
        <div  v-for="task in tasks" class="task row" v-if="!task.is_done">
          <div class="col-md-1 task-is-done">
            <el-checkbox v-model="task.is_done" v-on:change="updateTask(task)"></el-checkbox>
          </div>

          <div class="col-md-5">
            <inline-edit v-model.sync="task.title" v-on:input="updateTask(task)" placeholder="Title" class="title-input"></inline-edit>
          </div>
          <div class="col-md-4">
            <el-date-picker
             v-on:change="updateTask(task)"
             v-model="task.due_date"
             type="datetime"
             :editable="false"
             placeholder="Select date and time">
            </el-date-picker>
          </div>

          <div class="col-md-1">
            <select v-model="task.user_id" v-on:change="updateTask(task)">
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
        tasks: this.activities
      };
    },

    watch: {
      activities: function(){
        this.$data.tasks = this.activities;
      }
    },
    methods: {
      addTask() {
        var url = '/api/v2/activity/';
        this.$http.post(url, {
          activity: {
            contactId: this.contact.id,
            opportunityId: this.opportunity.id,
            userId: this.currentUserId,
            dueDate: new Date().toISOString(),
            companyId: this.company.id,
            title: 'Call',
            currentUserTimeZone: this.timeZone
          } });
      },
      removeTask(task) {
        var url = '/api/v2/activity/' + task.id;
        this.$http.delete(url);
        false;
      },
      updateTask(task) {
        var url = '/api/v2/activity/' + task.id;

        this.$http.put(url, {
          activity: {
            title: task.title,
            dueDate: task.due_date,
            contactId: this.contact.id,
            opportunityId: this.opportunity.id,
            userId: task.user_id,
            companyId: this.company.id,
            isDone: task.is_done
          }
        });
      }
    },
    components: {
      'inline-edit': InlineEdit,
      'checkbox': VueStrap.checkbox,
      'el-date-picker': Element.DatePicker,
      'el-checkbox': Element.Checkbox
    }
  };
</script>
