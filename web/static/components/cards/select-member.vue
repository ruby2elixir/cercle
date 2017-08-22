<template>
  <span v-on-click-outside='cancel'>
    <span v-on:click="showModal">
      <slot v-if="currentMember">
        <img :src="currentMember.profileImageUrl" class='profile-image' />
        {{currentMember.userName}}
      </slot>
    </span>

    <div v-show="editMode" class='input-modal'>
      <div class='modal-header clearfix'>
        <span>Members</span>
        <a class='close pull-right' v-on:click='cancel'>×</a>
      </div>

      <div class='modal-body'>
        <ul class='users-list'>
          <li v-for="user in users" @click="selectMember(user)">
            <img :src="user.profileImageUrl" class='profile-image' />
            {{ user.userName }}
            <i class="fa fa-check" v-if="user.id == value" />
          </li>
        </ul>
      </div>
    </div>
  </span>
</template>

<script>
export default {
  props: ['value', 'users'],
  data() {
    return {
      editMode: false
    };
  },
  computed: {
    currentMember() {
      for(var i=0; i<this.users.length; i++) {
        if(this.users[i].id === this.value)
          return this.users[i];
      }
    }
  },
  methods: {
    showModal: function() {
      this.editMode = true;
    },
    selectMember: function(user) {
      if(this.value !== user.id) {
        this.$emit('input', user.id);
        this.$emit('change');
      }
      this.editMode = false;
    },
    cancel: function() {
      this.editMode = false;
    }
  }
};
</script>

<style lang="sass" scoped>
  .modal-body {
    ul.users-list {
      li {
        width: 100%;
        float: none;
        text-align: left;
        cursor: pointer;
        padding: 5px 10px;

        &:hover {
          background-color: #298FCA;
          color: white;
        }
      }
    }

    .profile-image {
      max-width: 20px;
      max-height: 20px;
    }
  }
</style>
