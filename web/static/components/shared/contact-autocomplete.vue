<template>
  <div class="modal-body" v-on-click-outside='restoreSearchText'>
    <input type="search" class="form-control" v-model='search' @keyup="searchContacts" placeholder="Search contact..." ref='search' />

    <ul class='search-list' v-if="showList">
      <li v-for="contact in contacts" @click="selectContact(contact)">
        <h4>{{ contact.name }}</h4>
        <div><small>{{ contact.email }}</small></div>
        <div><small>{{ contact.phone }}</small></div>
      </li>

      <li @click="addNew" class="add-new"><h4>Create: {{ search }}</h4></li>
    </ul>
  </div>
</template>

<script>
  export default {
    props: [],
    data() {
      return {
        showList: false,
        search: '',
        name: '',
        contacts: [],
        data: {}
      };
    },
    components: {
    },
    watch: {
    },
    methods: {
      restoreSearchText() {
        if(this.data.contact) {
          this.search = this.data.contact.name;
        } else {
          this.search = '';
        }
        this.showList = false;
      },
      searchContacts() {
        if(this.search === '') {
          this.contacts = [];
          this.showList = false;
        } else {
          this.$http.get('/api/v2/company/'+ Vue.currentUser.companyId +'/contact?q=' + this.search).then(resp => {
            this.contacts = resp.data.data;
            this.showList = true;
          });
        }
      },
      addNew() {
        this.showList = false;
        this.data = {
          newContact: true,
          contact: {
            name: this.search
          }
        };
        this.$emit('change', this.data);
      },
      selectContact(contact) {
        this.showList = false;
        this.search = contact.name;
        this.data = {
          newContact: false,
          contact: contact
        };
        this.$emit('change', this.data);
      }
    }
  };
</script>

<style lang="sass" scoped>
  .modal-body {
    ul.search-list {
      list-style: none;
      padding: 0;
      border-left: 1px solid lightgray;
      border-right: 1px solid lightgray;
      border-bottom: 1px solid lightgray;
      min-width: 200px;
      min-height: 200px;
      position: absolute;
      left: 0;
      right: 0;
      background: white;
      z-index: 1;

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
  }
</style>
