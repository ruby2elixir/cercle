<template>

  <div class="box" >

    <div class="box-body box-profile" style="text-align:center;" v-if="!company">
      <a href="#sd" style="font-size:16px;" v-on:click="buildCompany">+Add a company</a>
    </div><!-- /.box-body -->
    <div class="box-body box-profile" v-if="company">
      <div class="box-tools pull-right">
        <button type="button" class="btn btn-box-tool" ><i class="fa fa-fw fa-angle-down"></i></button>
      </div>
      <h3 class="profile-username">
         <inline-edit v-model.lazy="company.title" v-on:input="update" placeholder="Company Name"></inline-edit>
      </h3>
      <ul class="list-group list-group-unbordered" style="margin-bottom:5px;">
        <li class="list-group-item" style="padding-bottom:4px;">
        </li>
      </ul>

    </div><!-- /.box-body -->
  </div><!-- /.box -->
</template>

<script>
  import InlineEdit from '../inline-common-edit.vue';
  export default {
    props: ['company'],
    methods: {
      update: function(){  this.$emit('update', this.company);  },
      buildCompany: function(){
        this.$emit('buildCompany');
      }
    },
    components: { 'inline-edit': InlineEdit  }
  };
</script>
