<template>
  <span v-on-click-outside='cancel'>
    <span v-on:click="showModal">
      <slot>
        <span v-if="currentMember">
          <img :src="currentMember.profileImageUrl" class='profile-image' :title="currentMember.userName" />
          <span v-if="!displayShort">{{currentMember.userName}}</span>
        </span>
        <span v-else>{{ placeholder }}</span>
      </slot>
    </span>

    <div v-show="editMode" class='input-modal'>
      <div class='modal-header clearfix'>
        <span>Members</span>
        <a class='close pull-right' v-on:click='cancel'>×</a>
      </div>

      <div class='modal-body'>
        <ul class='users-list'>
          <li :class='memberClass(user)' v-for="user in users" @click="toggleMemberSelection(user)">
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
  props: ['value', 'users', 'displayShort', 'placeholder'],
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
    memberClass(user) {
      if(this.value === user.id)
        return 'active';
    },
    showModal: function() {
      this.editMode = true;
    },
    toggleMemberSelection: function(user) {
      if(this.value === user.id) {
        this.$emit('input', '');
      } else {
        this.$emit('input', user.id);
      }
      this.$emit('change');
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
        border-radius: 0;

        &:hover {
          background-color: lightblue;
        }

        &.active {
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
