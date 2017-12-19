<template>
  <div class="box box-primary">
    <div class="box box-primary">
      <el-form ref="form" :model="company" label-width="150px">
        <div class="box-header with-border">
          <h3 class="box-title">Company</h3>
        </div><!-- /.box-header -->
        <div class="box-body">


          <el-form-item label="Company's Name" :rules="[{required: true} ]">
            <el-input v-model="company.title"></el-input>
          </el-form-item>

          <el-form-item label="Company Logo">
            <div class="col-md-10">
              <input v-on:change="chooseImage" type="file" />
            </div>
            <div class="col-md-2">
              <div v-if="previewImage">
                <img :src="previewImage" width="75"  />
              </div>
            </div>
          </el-form-item>

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
    props: ['companyId', 'id'],
    data() {
      return {
        previewImage: null,
        company: {}
      }
    },
    methods: {
      chooseImage(e) {
        let files = e.target.files || e.dataTransfer.files;
        if (!files.length)
          return;
        this.createImage(files[0]);
      },
      createImage(file) {
        this.form.logoImage = file;
        let image = new Image();
        let reader = new FileReader();
        let vm = this;

        reader.onload = (e) => {
          vm.previewImage = e.target.result;
        };
        reader.readAsDataURL(file);
      },

      save() {
        this.$refs.form.validate((valid) => {
          if (valid) {
            let formData = new FormData();
            formData.append('company[title]', this.company.title);
            if (this.company.logoImage) {
              formData.append(
                'company[logo_image]',
                this.company.logoImage,
                this.company.logoImage.name
              );
            }
            let url = '/api/v2/companies/' + this.id;
            this.$http.put(url, formData).then(resp => {
              this.$router.push("/company/" + this.companyId + "/settings/companies/");
            })
          } else {
            return false;
          }
        })
      },
      fetchCompany() {
        let url = "/api/v2/companies/" + this.id;
        this.$http.get(url).then(resp => {
          this.company = resp.data.data
          this.previewImage = this.company.logo;
        })
      }
    },
    mounted() {
      this.fetchCompany();
    }
  };
</script>
<style lang="sass" scoped>

  </style>
