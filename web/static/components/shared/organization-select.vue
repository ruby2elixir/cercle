<template>
  <div v-on-click-outside='close'>
    <span v-if="organization">
      <slot>{{ organization.name }}</slot>
    </span>

    <span class='add-organization' v-on:click="showModal" v-else>
      Click to add
    </span>

    <div v-show="selectMode" class='input-modal organization-select-modal'>
      <div class='modal-header clearfix'>
        <span>Select/Add organization</span>
        <a class='close pull-right' v-on:click='close' v-if="!inline">×</a>
      </div>

      <div class='modal-body'>
        <input type="search" class="form-control" v-model='search' @keyup="searchOrganizations" placeholder="Search organization..." ref='search' />

        <ul class='search-list'>
          <li v-for="organization in organizations" @click="selectedOrganization=organization.id" :class="{selected: organization.id == selectedOrganization}">
            <h4>{{ organization.name }}</h4>
            <div><small>{{ organization.website }}</small></div>
            <div><small>{{ organization.description }}</small></div>
          </li>

          <li @click="selectedOrganization='addNew'" :class="{selected: selectedOrganization == 'addNew', 'add-new': true}" v-if="search">Add: {{ search }}</li>
        </ul>
      </div>

      <div class="input-modal-footer">
        <div class="text-right">
          <button class="btn btn-primary save" @click="save" :disabled="!selectedOrganization">Save</button>
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
        organizations: [],
        selectedOrganization: '',
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
      showModal() {
        this.selectMode = true;
        let vm = this;
        Vue.nextTick(function(){
          vm.$refs.search.focus();
        });
      },
      reset() {
        this.organizations = [];
        this.search = '';
      },
      searchOrganizations() {
        this.addNew = false;
        this.selectedOrganization = '';

        if(this.search === '') {
          this.organizations = [];
        } else {
          this.$http.get('/api/v2/company/'+ Vue.currentUser.companyId +'/organizations?q=' + this.search).then(resp => {
            this.organizations = resp.data.data;
          });
        }
      },
      close: function() {
        this.selectMode = false;
        this.reset();
      },
      getOrganizationSelection() {
        for(var i=0; i<this.organizations.length; i++) {
          if(this.organizations[i].id === this.selectedOrganization)
            return this.organizations[i];
        }
      },
      addOrganization() {
        let url = '/api/v2/company/'+ Vue.currentUser.companyId +'/organizations';
        this.$http.post(url, { organization: { name: this.name, website: this.website, description: this.description }}).then(resp => {
          this.selectOrganization(resp.data.data);
        });
      },
      selectOrganization(organization) {
        this.selectedOrganization = organization.id;
        this.$emit('change', organization);
        this.close();
      },
      save() {
        if(this.selectedOrganization === 'addNew') {
          this.name = this.search;
          this.addOrganization();
        } else {
          this.selectOrganization(this.getOrganizationSelection());
        }
        this.reset();
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
      border-bottom: 1px solid lightgray;
      min-width: 200px;
      min-height: 200px;

      li {
        padding: 5px;
        border-bottom: 1px solid lightgray;
        cursor: pointer;

        &:last-child {
          border-bottom: none;
        }

        &:hover, &.selected {
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

    .input-modal-footer {
      padding: 0 10px 5px;
    }
  }
</style>
