<template>
  <div>
    <div class="box box-primary">

      <el-form :model="form" :rules="validateRules" ref="profileEditForm" label-width="120px"  :label-position="'top'" >
        <div class="box-header with-border">
          <h3 class="box-title">Profile</h3>
        </div>
        <div class="box-body">
        <el-form-item label="Full Name" prop="fullName">
          <el-input v-model="form.fullName"></el-input>
        </el-form-item>
        <el-form-item label="Username" prop="username">
          <el-input v-model="form.username"></el-input>
        </el-form-item>


        <el-form-item prop="notification">
          <label>
            <el-checkbox v-model="form.notification"></el-checkbox>
            Receive email notifications
          </label>
        </el-form-item>

        <el-form-item label="Email" prop="login">
          <el-input v-model="form.login"></el-input>
        </el-form-item>

        <el-form-item label="Password" prop="password">
          <el-input v-model="form.password" type="password"></el-input>
        </el-form-item>

        <el-form-item label="Time Zone" prop="timeZone">
          <el-select v-model="form.timeZone" filterable placeholder="Choose your Time Zone" style="width:500px">
            <el-option
              v-for="item in timeZones"
              :key="item.value"
              :label="item.label"
              :value="item.value">
            </el-option>
          </el-select>
        </el-form-item>
        <div class="row">
          <div class="col-md-10">
          <input v-on:change="chooseImage" type="file" />
          </div>
          <div class="col-md-2">
          <div v-if="previewImage">
            <img :src="previewImage" width="75"  />
          </div>
          </div>
        </div>
        </div>
        <div class="box-footer">
          <el-button type="primary" @click="save()" class="btn btn-primary pull-right">Save</el-button>
        </div>
      </el-form>
    </div>
  </div>
</template>
<script>
  export default {
    props: [],
    data() {
      return {
        timeZones: this.listTimeZones(),
        previewImage: null,
        validateRules: {
          fullName: [],
          username: [ { required: true, trigger: 'blur' }  ],
          login: [ { required: true, message: 'email is required',  trigger: 'blur' }  ]
        },
        form: {
          fullName: null,
          username: null,
          login: null,
          timeZone: null,
          password: null
        }
      };
    },
    methods: {
      chooseImage(e) {
        let files = e.target.files || e.dataTransfer.files;
        if (!files.length)
          return;
        this.createImage(files[0]);
      },
      createImage(file) {
        this.form.profileImage = file;
        let image = new Image();
        let reader = new FileReader();
        let vm = this;

        reader.onload = (e) => {
          vm.previewImage = e.target.result;
        };
        reader.readAsDataURL(file);
      },

      save() {
        this.$refs.profileEditForm.validate((valid) => {
          if (valid) {
            let formData = new FormData();
            formData.append('user[full_name]', this.form.fullName);
            formData.append('user[username]', this.form.username);
            formData.append('user[notification]', this.form.notification);
            formData.append('user[login]', this.form.login);
            formData.append('user[time_zone]', this.form.timeZone);
            if (!this.$_.isEmpty(this.form.password)) {
              formData.append('user[password]', this.form.password);
            }
            if (this.form.profileImage) {
              formData.append(
                'user[profile_image]',
                this.form.profileImage,
                this.form.profileImage.name
              );
            }
            this.$http.put('/api/v2/profile', formData).then(resp => {
              this.$notify({
                title: '',
                message: 'User updated successfully.',
                type: 'success'
              });
            });
          } else {
            return false;
          }
        });
      },
      fetchProfile() {
        this.$http.get('/api/v2/profile').then(resp => {
          this.form = resp.data;
          this.previewImage = this.form.profileImageUrl;
        });
      }
    },
    mounted() {
      this.fetchProfile();
    }
  };
  </script>
<style lang="sass">
  .el-menu.el-settings-menu {

li {
  height: 40px;
  line-height: 40px;
  border-bottom: 1px solid #f4f4f4;
  }
    }
</style>
