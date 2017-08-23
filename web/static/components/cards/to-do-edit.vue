<template>
  <div class="card-to-dos">
    <div>
      <div class="pull-right toggle-done-tasks" v-if="tasks.length>0">
        <a v-if="!showDoneTasks" @click="showDoneTasks=true;" href='#'><i class="fa fa-eye"></i> Show done tasks</a>
        <a v-if="showDoneTasks" @click="showDoneTasks=false;" href='#'><i class="fa fa-eye-slash"></i> Hide done tasks</a>
      </div>

      <h3 style="color:rgb(99,99,99);font-weight:bold;">
        <i class="fa fa-fw fa-check-square-o" style="color:#d8d8d8;"></i>Tasks
      </h3>

      <div style="padding:15px;">
        <div  v-for="task in tasks" class="task row" v-if="showDoneTasks || !task.isDone">
          <div class="col-md-1 task-is-done">
            <el-checkbox v-model="task.isDone" v-on:change="updateTask(task)"></el-checkbox>
          </div>

          <div class="col-md-5">
            <inline-edit v-model.sync="task.title" v-on:input="updateTask(task)" placeholder="Title" class="title-input"></inline-edit>
          </div>
          <div class="col-md-4">
            <el-date-picker
             v-on:change="updateTask(task)"
             v-model="task.dueDate"
             type="datetime"
             :editable="false"
             size="small"
             placeholder="Select date and time">
            </el-date-picker>
          </div>

          <div class="col-md-1">
            <select-member v-model.number="task.userId" @change="updateTask(task)" :users="companyUsers" :display-short="true" placeholder="N/A" />
          </div>

          <div class="col-md-1 remove-task">
            <button class="btn btn-link" v-on:click="removeTask(task)"> <i class="fa fa-fw fa-close"></i></button>
          </div>
        </div>


      </div>
      <div class="add-to-do">
        <button  class="btn btn-link" v-on:click="addTask"><i class="fa fa-fw fa-plus"></i> Add a task...</button>
      </div>
      <br />
      <slot name="attachments"></slot>
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
  import SelectMember from '../shared/select-member.vue';
  export default {
    props: {
      timeZone: String,
      currentUserId: String,
      activities: { type: Array, default: [] },
      companyUsers: { type: Array, default: [] },
      card: Object,
      company: Object
    },
    data() {
      return {
        tasks: this.activities,
        showDoneTasks: true
      };
    },

    watch: {
      activities: function(){
        this.$data.tasks = this.activities;
      }
    },
    methods: {
      shortUserName(user) {
        let shortName = '';
        if (user.userName) {
          shortName = user.userName.toUpperCase().slice(0, 2);
        }
        return shortName;
      },
      addTask() {
        let url = '/api/v2/activity/';
        this.$http.post(url, {
          activity: {
            cardId: this.card.id,
            userId: this.currentUserId,
            dueDate: new Date().toISOString(),
            companyId: this.company.id,
            title: 'Call',
            currentUserTimeZone: this.timeZone
          } }); //.then( resp => { this.$emit('taskAddOrUpdate', resp.data.data); });
      },
      removeTask(task) {
        let url = '/api/v2/activity/' + task.id;
        this.$http.delete(url); //.then( resp => { this.$emit('taskDelete', task.id); });
        false;
      },
      updateTask(task) {
        let url = '/api/v2/activity/' + task.id;

        this.$http.put(url, {
          activity: {
            title: task.title,
            dueDate: task.dueDate,
            cardId: this.card.id,
            userId: task.userId,
            companyId: this.company.id,
            isDone: task.isDone
          }
        }); //.then( resp => { this.$emit('taskAddOrUpdate', resp.data.data); });
      }
    },
    components: {
      'inline-edit': InlineEdit,
      'checkbox': VueStrap.checkbox,
      'el-date-picker': ElementUi.DatePicker,
      'el-checkbox': ElementUi.Checkbox,
      'select-member': SelectMember
    }
  };
</script>
