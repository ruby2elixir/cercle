<template>
  <div>
    <!-- Content Header (Page header) -->
    <section class="content-header" style="margin-top:20px;margin-bottom:20px;">
      <h2>People<br /> <span style="font-size:16px;color:grey;">{{contacts.length}} contacts</span></h2>

      <div class="row">
        <div class="col-xs-6">
          <form  style="max-width:300px;" role="search" v-on:submit.prevent>
            <div class="input-group add-on">
              <input class="form-control" placeholder="Search" name="q" type="text" v-model="searchTerm" />
              <div class="input-group-btn">
                <button class="btn btn-default" type="submit" v-on:click.stop.prevent="searchContacts">
                  <i class="glyphicon glyphicon-search"></i></button>
              </div>
            </div>
          </form>
        </div>

        <div class="col-xs-6">
          <div class="btn-group pull-right" role="group">
            <button v-if="contactList.length > 0" type="button" class="btn btn-danger" @click="deleteSelectContacts">
              Delete contacts
            </button>
            <button v-if="contactList.length > 0" type="button" class="btn btn-default" @click="exportSelectContacts">
              Export contacts
            </button>
            <router-link :to="'/company/' + company_id + '/contact/new'" class="pull-right btn btn-primary">
              + Add a Contact
            </router-link>
          </div>
        </div>
      </div>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="row">
        <div class="col-xs-12">
          <div class="box" style="border:0px solid grey;">

            <!-- /.box-header -->
            <div class="nav-tabs-custom ">
              <div class="list">

                <el-table :data="contacts" style="width: 100%"
                          border
                          :stripe="true"
                          size="mini"
                          @selection-change="handleSelectRow"
                          :row-class-name="rowClassName">
                  <el-table-column prop="id" size="mini" type="selection"
                                   :class-name="'row-contact'"
                                   width=40>
                  </el-table-column>
                  <el-table-column label="Name">
                    <template slot-scope="scope">
                      <router-link :to="contactUrl(scope.row)" class="contact-link">
                        {{scope.row.firstName}} {{scope.row.lastName}}
                      </router-link>
                    </template>
                  </el-table-column>
                  <el-table-column label="Job Title">
                    <template slot-scope="scope">
                      <router-link :to="contactUrl(scope.row)" class="contact-link">
                          {{scope.row.jobTitle}}
                        </router-link>
                    </template>
                  </el-table-column>
                  <el-table-column label="Organization">
                    <template slot-scope="scope">
                      <router-link :to="contactUrl(scope.row)" class="contact-link">
                          {{scope.row.organization && scope.row.organization.name}}
                        </router-link>
                    </template>
                  </el-table-column>
                  <el-table-column label="Email">
                    <template slot-scope="scope">
                      <router-link :to="contactUrl(scope.row)" class="contact-link">
                        {{scope.row.email}}
                      </router-link>
                    </template>
                  </el-table-column>
                  <el-table-column  label="Phone">
                    <template slot-scope="scope">
                      <router-link :to="contactUrl(scope.row)" class="contact-link">
                          {{scope.row.phone}}
                        </router-link>
                    </template>
                  </el-table-column>
                  <el-table-column width=80 label="Tags">
                    <template slot-scope="scope">
                      <router-link :to="contactUrl(scope.row)" class="contact-link">
                        <span v-for="tag in scope.row.tags">{{tag.name}} </span>
                      </router-link>
                    </template>
                  </el-table-column>
                  <el-table-column width=120 label="Last Updated">
                    <template slot-scope="scope">
                      <router-link :to="contactUrl(scope.row)" class="contact-link">
                        <span style="color:grey;font-size:14px;">{{scope.row.updatedAt | moment("from")}}</span>
                      </router-link>
                    </template>
                  </el-table-column>
                </el-table>
                  <el-pagination
                    layout="prev, pager, next"
                    background
                    @current-change="handleChangePage"
                    :total="totalContacts"
                    :page-size="pageSize"

                    >
                  </el-pagination>

              </div>

            </div><!-- /.box-body -->
          </div><!-- /.box -->
        </div>
      </div>

    </section><!-- /.content -->
  </div>
</template>

<script>
  import {Socket, Presence} from 'phoenix';
  import moment from 'moment';
  export default {
    props: ['company_id'],
    data() {
      return {
        contactList: [],
        contacts: [],
        socket: null,
        channel: null,
        searchTerm: '',
        totalContacts: 0,
        pageSize: 15
      };
    },

    beforeRouteEnter (to, from, next) {
      next(vm => {
        if (to.name === 'contactPage') {
          vm.getContactAndOpen(to.params.contactId);
        }
      });
    },
    beforeRouteLeave (to, from, next) {
      this.$glmodal.$off('onCloseModal');
      next();
    },
    watch: {
      '$route' (to, from) {
        if (to.name === 'contactPage') {
          this.getContactAndOpen(to.params.contactId);
        }
        if (from.name === 'contactPage') { this.$glmodal.$emit('close'); }
      }
    },

    components: {
      'modal': VueStrap.modal,
      'el-checkbox': ElementUi.Checkbox,
      'el-checkbox-group': ElementUi.CheckboxGroup
    },

    methods: {
      rowClassName(item) {
        return 'contact-row-'+ item.row.id;
      },
      handleChangePage(page) {
        this.loadContacts({page: page});
      },
      getContactAndOpen(contactId) {
        let vm = this;
        let contact = vm.$_.find(
          vm.contacts, {id: vm.$_.toInteger(contactId)}
        );
        if (contact === undefined) {
          let url = '/api/v2/company/' + vm.company_id + '/contact/' + contactId;
          vm.$http.get(url).then(resp => { vm.contactShow(resp.data.contact); });
        } else {
          vm.contactShow(contact);
        }
      },
      contactUrl(contact) {
        return '/company/' + Vue.currentUser.companyId + '/contact/' + contact.id;
      },
      deleteSelectContacts() {
        if(confirm('Are you sure do to delete selected contacts?')) {
          let url = '/api/v2/company/' + this.company_id + '/contact/multiple/delete';
          let contactIds = this.$_.map(this.contactList, 'id');
          this.$http.delete(
            url, {body: {contactIds: contactIds}}
          ).then(resp => {
            this.contactList = [];
            this.loadContacts();
          });

        }
      },
      exportSelectContacts() {
        let url = '/api/v2/company/' + this.company_id + '/contact/export';
        let contactIds = this.$_.map(this.contactList, 'id');
        this.$http.post(url, { contactIds: contactIds })
          .then(resp => {
            let headers = resp.headers;
            let contentDisposition = headers.get('Content-Disposition') || '';
            let filename = contentDisposition.split('filename=')[1];
            filename = filename.replace(/"/g,'');

            let blob = new Blob([resp.data],{type:headers['content-type']});
            let link = document.createElement('a');
            link.href = window.URL.createObjectURL(blob);
            link.target = '_self';
            link.download = filename;
            link.click();
          });
      },
      handleSelectRow(selectedContacts) {
        this.contactList = selectedContacts;
      },
      searchContacts() {
        let params = {};
        if (this.searchTerm !== '') {
          params = { q: this.searchTerm };
        }
        this.loadContacts(params);
      },
      contactShow(contact) {
        let vm = this;
        vm.$glmodal.$off('onCloseModal');
        vm.$glmodal.$once('onCloseModal', function() {
          vm.$router.push({
            path: `/company/${vm.company_id}/contact`
          });
        });

        this.$glmodal.$emit(
          'open',
          {
            view: 'contact-show', class: 'contact-modal',
            data: { 'contact': contact }
          }
        );
      },
      loadContacts(opts){
        let url = '/api/v2/company/' + this.company_id + '/contact';
        let params = opts || {};
        this.$http.get(url, { params: params }).then(resp => {
          this.contacts = resp.data.data;
          this.totalContacts = resp.data.meta.totalEntries;
          this.pageSize = resp.data.meta.pageSize;
        });

      },
      initConn(){

        this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
        this.socket.connect();
        this.loadContacts();
      },
      setAuthToken(){
        let vm = this;
        vm.initConn();
      }
    },
    mounted(){
      this.setAuthToken();
    }
  };

</script>
<style lang="sass">
  .contact-link {
  color: black;
  &:hover { color: black;
  }
  }
  .el-checkbox__label { display: none }
  .contact-modal {
  .modal-header {
  border: none;
  }
  button.close {
  position: absolute;right: 10px;top: 4px; z-index: 999;
  }
  }
</style>
