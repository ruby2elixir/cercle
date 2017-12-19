<template>
  <div class="box box-primary">
    <div class="box-header with-border">
      <h3 class="box-title">Team</h3>
    </div><!-- /.box-header -->
    <div class="box-body">


      <el-form :inline="true" ref="inviteForm" :model="inviteForm" >

        <div class="row">
          <div class="col-md-9">
            <div class="form-group">
              <el-input :required='true' v-model="inviteForm.email" placeholder="Type an email address" width="100%"></el-input>
            </div>
          </div>
          <div class="col-md-3">
            <el-button type="info" @click="invite()" :disabled="disabledInvite"> Invite </el-button>
          </div>
        </div>

      </el-form>

      <div class="row">
        <div class="col-md-12">
          <h4>Members of {{company.title}}</h4>

          <el-table
            :show-header="false"
            :data="users"
            style="width: 100%">
            <el-table-column prop="profile_image_url" label="" width="100" >
              <template slot-scope="scope">
                <img :src="scope.row.profileImageUrl" class="user-image"/>
              </template>
            </el-table-column>
            <el-table-column prop="fullName" >
              <template slot-scope="scope">
                {{scope.row.fullName}}
                <br />
                {{scope.row.login}}
              </template>
            </el-table-column>
            <el-table-column prop="name" >
            </el-table-column>
            <el-table-column width="100">
              <template slot-scope="scope">
                <el-button @click="deleteMember(scope.row)" type="text" v-show="canRemove(scope.row)">Remove</el-button>
              </template>
            </el-table-column>
          </el-table>

        </div>
      </div>
    </div>
  </div>

</template>
<script>
  export default {
    props: ['companyId'],
    data() {
      return {

        inviteForm: { email: null },
        company: {},
        users: []
      }
    },
    computed: {
      disabledInvite() {
        return this.$_.isEmpty(this.inviteForm.email)
      }
    },
    methods: {
      invite() {
        let url = "/api/v2/company/" + this.companyId + "/settings/team/invitation";
        this.$http.post(url, { user: { email: this.inviteForm.email }}).then(resp => {
          this.inviteForm.email = null;
          this.$message({
            message: 'Invitation link sent successfully!',
            type: 'success'
          });
        })
      },
      deleteMember(user) {
        if(confirm('Are you sure?')) {
          let url = "/api/v2/company/" + this.companyId + "/settings/team/" + user.id;
          this.$http.delete(url).then(resp => {
            let userIndex = this.users.findIndex(function(u){
              return u.id === user.id;
            });

            this.users.splice(userIndex, 1);
          })
        }
      },
      canRemove(user) { return !Vue.currentUser.eq(user.id) },
      fetchData() {
        let url = "/api/v2/companies/" + this.companyId;
        this.$http.get(url).then(resp => {
          this.company = resp.data.data
        });
        let userUrl = "/api/v2/company/" + this.companyId + "/company/users";
        this.$http.get(userUrl).then(resp => {
          this.users = resp.data.users
        });
      }
    },
    mounted() {
      this.fetchData();
    }
  };
  </script>
<style lang="sass" scoped>
  .user-image {
  padding:4px;
  width:40px;
  border-radius:128px;
  }
</style>
