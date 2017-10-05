<template>
  <div v-on-click-outside='close'>
    <div class="box-body box-profile" v-if="organization">
      <div>
        Working at <inline-edit v-model="organization.name" v-on:input="update" placeholder="Organization Name"></inline-edit>
        <button v-on:click="removeOrganization" class="btn btn-link removeOrg">Remove</button>
      </div>
      <inline-edit v-model="organization.website" v-on:input="update" placeholder="Website"></inline-edit>
      <inline-text-edit v-model="organization.description" v-on:input="update" placeholder="Note about the organization"></inline-text-edit>
    </div><!-- /.box-body -->

    <span v-on:click="selectMode=true" v-else>
      Add organization
    </span>

    <div v-show="selectMode" class='input-modal'>
      <div class='modal-header clearfix'>
        <span>Select/Add organization</span>
        <a class='close pull-right' v-on:click='close' v-if="!inline">×</a>
      </div>

      <div class='modal-body'>
        <input type="text" class="form-control" v-model='search' @keyup="searchOrganizations" placeholder="Search organization..." />
        <div v-if="addNew">
          <inline-edit class="form-control" v-model="name" v-on:input="update" placeholder="Organization Name" ref="newname"></inline-edit>
          <inline-edit class="form-control" v-model="website" v-on:input="update" placeholder="Website"></inline-edit>
          <inline-text-edit class="form-control" v-model="description" v-on:input="update" placeholder="Note about the organization"></inline-text-edit>

          <div>
            <button class='btn btn-primary btn-block' @click='addOrganization'>Add</button>
          </div>
        </div>
        <div v-else>
          <ul class='search-list'>
            <li v-for="organization in organizations" @click="selectOrganization(organization)">
              <h4>{{ organization.name }}</h4>
              <div><small>{{ organization.website }}</small></div>
              <div><small>{{ organization.description }}</small></div>
            </li>

            <li>
              <a class='add-new' @click="showAddNew">Add new</a>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import InlineEdit from '../shared/inline-common-edit.vue';
  import InlineTextEdit from '../shared/inline-textedit.vue';

  export default {
    props: ['organization'],
    data() {
      return {
        search: '',
        name: '',
        website: '',
        description: '',
        organizations: [],
        addNew: false,
        selectMode: false
      };
    },
    components: {
      'inline-edit': InlineEdit,
      'inline-text-edit': InlineTextEdit
    },
    watch: {
    },
    methods: {
      searchOrganizations() {
        this.addNew = false;

        if(this.search === '') {
          this.organizations = [];
        } else {
          this.$http.get('/api/v2/company/'+ Vue.currentUser.companyId +'/organizations/search/' + this.search).then(resp => {
            this.organizations = resp.data.data;
          });
        }
      },
      close: function() {
        this.selectMode = false;
      },
      showAddNew() {
        this.addNew = true;
        let vm = this;
        Vue.nextTick(function(){
          vm.name = vm.search;
          vm.search = '';
          vm.$refs.newname.$refs.input.focus();
        });
      },
      addOrganization() {
        let url = '/api/v2/company/'+ Vue.currentUser.companyId +'/organizations';
        this.$http.post(url, { organization: { name: this.name, website: this.website, description: this.description }}).then(resp => {
          this.organizations.push(resp.data.data);
          this.selectOrganization(resp.data.data);
          this.addNew = false;
        });
      },
      selectOrganization(organization) {
        this.$emit('update', organization);
        this.close();
      },
      removeOrganization() {
        this.$emit('update', null);
      }
    }
  };
</script>

<style lang="sass" scoped>
  .input-modal {
    z-index: 10;
  }

  .modal-body {
    ul.search-list {
      list-style: none;
      padding: 0;
      border-left: 1px solid lightgray;
      border-right: 1px solid lightgray;

      li {
        padding: 5px;
        border-bottom: 1px solid lightgray;
        cursor: pointer;

        &:hover {
          background-color: dodgerblue;
          color: white;

          a {
            color: white;
          }
        }

        h4 {
          margin: 0;
        }

        .add-new {
          display: block;
          text-align: center;
          font-weight: bold;
        }
      }
    }
  }
</style>
