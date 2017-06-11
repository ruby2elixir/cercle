<template>
  <span v-on-click-outside='cancel'>
    <span v-on:click="showModal" class='current-value'>
      {{ currentBoard().name }}
      <i class="fa fa-caret-down" />
    </span>

    <div v-show="editMode" class='input-modal'>
      <div class='modal-body'>
        <ul>
          <li v-for="column in columns" @click="save(column.id)">
            {{ column.name }}
            <i class="fa fa-check" v-if="value == column.id" />
          </li>
        </ul>
      </div>
    </div>
  </span>
</template>

<style scoped>
  .current-value {
    cursor: pointer;
  }

  .input-modal {
    z-index: 10;
  }

  .modal-body {
    padding: 0;
  }

  .modal-body ul {
    list-style: none;
    padding: 0;
    font-size: 18px;
    font-weight: normal;
  }

  .modal-body ul li {
    cursor: pointer;
    padding: 3px 10px;
    border-radius: 0;
  }

  .modal-body ul li:hover {
    background: #3c8dbc;
    color: #ffffff;
  }
</style>

<script>
export default {
  props: ['value', 'columns', 'label'],
  data() {
    return {
      editMode: false
    };
  },
  computed: {
  },
  methods: {
    currentBoard() {
      for(var i=0; i < this.columns.length; i++) {
        if(this.columns[i].id == this.value) {
          return this.columns[i];
        }
      }

      return {name: '--'};
    },
    showModal: function() {
      this.editMode = true;
    },
    save: function(id) {
      this.$emit('input', id);
      this.$emit('change');
      this.editMode = false;
    },
    cancel: function() {
      this.editMode = false;
    }
  }
};
</script>
