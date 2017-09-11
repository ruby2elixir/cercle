<template>
  <ul class="nav navbar-nav user-navbar">
    <li class="current-company">
      <a style="" href='#'>
        <img height=25 :src="company.logo_url" />
        {{company.title}}
        </a>
    </li>
    <!-- Messages: style can be found in dropdown.less-->
    <!-- User Account Menu -->
    <li class="dropdown user user-menu">
      <!-- Menu Toggle Button -->
      <a href="#" class="dropdown-toggle" data-toggle="dropdown">
        <!-- The user image in the navbar-->
        <img v-if="user.profile_image_url" :src="user.profile_image_url" class="user-image">
        <img v-else class="user-image" src="/images/pp_2.png">
        <!-- hidden-xs hides the username on small devices so only the image appears. -->
        <span class="hidden-xs">{{user.user_name}}</span>
      </a>

      <ul class="dropdown-menu">
        <!-- The user image in the menu -->
        <li class="user-header">
          <img v-if="user.profile_image_url" :src="user.profile_image_url" class="img-circle">
          <img v-else class="img-circle" src="/images/pp_2.png">
          <p>
            {{user.user_name}}
            <small>
              ({{user.name}})
            </small>
          </p>
        </li>


        <li class="user-company" v-for="c in list_companies" :key="c.id">
          <a :href="'/company/' + c.id + '/board'">
          <img height=100 :src="c.logo_url" />
          <div class='company-title'>{{c.title}}</div>
          </a>
        </li>

        <li class="user-footer">
          <div class="pull-left">
            <a :href="settingsUrl()" class="btn btn-default btn-flat">Settings</a>
          </div>
          <div class="pull-right">
            <a href="/logout" class="btn btn-default btn-flat">Sign out</a>
          </div>
        </li>
      </ul>

    </li>

  </ul>
</template>
<script>
  export default {
  props: ['user', 'company', 'companies'],
  data() {
  return {};
  },
    methods: {
      settingsUrl() {
        return '/company/' + Vue.currentUser.companyId + '/settings/profile';
      }
    },
    computed: {
      list_companies() {
        return this.companies.filter((v) => v.id !== this.company.id);
      }
    },
  mounted(){ }
  };
</script>

<style lang="sass">
  .user-navbar {
    .current-company {
      img {
        margin-right:5px;
        }
   }
  .user-company {
    img {
      min-width: 50px;
      min-height: 50px;
      height: 50px;
    }
    }
      .company-title {
        margin-left: 25px;
  display: inline-block;
  }
  .user-header {
  background-color:#3C8DBC;
  p {
  color:#FFFFFF;
  }
  }
  }
</style>
