<template>
  <div class="box box-primary">
    <div class="box-header with-border">
      <h3 class="box-title">Companies</h3>
      <div class="pull-right">
        <router-link
          :to="'/company/' + companyId + '/settings/companies/new'"
          class='el-button el-button--info el-button--small'>
          Add Company
        </router-link>
      </div>
    </div><!-- /.box-header -->
    <div class="box-body" style="padding:0px;">
      <el-table
        :data="companies"
        style="width: 100%">
        <el-table-column
          prop="logo"
          label="Logo"
          width="100"
          >
          <template slot-scope="scope">
            <img :src="scope.row.logo" style="max-width:50px;padding:2px;"/>
          </template>
      </el-table-column>
      <el-table-column
        prop="title"
        label="Name"
        >
      </el-table-column>
      <el-table-column
        label=""
        width="180">
        <template slot-scope="scope">
          <div class="pull-right">
            <router-link
              :to="'/company/' + companyId + '/settings/companies/' + scope.row.id + '/edit'"
              class='el-button el-button--default el-button--small'>
              Edit
            </router-link>
          </div>
        </template>
      </el-table-column>
    </el-table>
    </div>
  </div>
</template>
<script>
  export default {
    props: ['companyId'],
    data() { return { companies: [] };  },
    methods: {
      fetchCompanies() {
        let url = "/api/v2/companies";
        this.$http.get(url).then(resp => { this.companies = resp.data.data });
      }
    },
    computed: {
    },
    mounted() {
      this.fetchCompanies();
    }
  };
</script>
<style lang="sass" scoped>

  </style>
