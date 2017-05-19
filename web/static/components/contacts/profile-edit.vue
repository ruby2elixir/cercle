<template>
    <div class="">
      <div class="">
        <h3 class="profile-username" style="margin-right:30px;line-height: 30px;height: 30px;font-size:24px;font-weight:bold;color:rgb(99,99,99);">
          <i class="fa fa-user" style="color:#d8d8d8;"></i>
          <name-input-modal :first-name="contact.first_name" :last-name="contact.last_name" v-on:input="nameInput"/>
        </h3>
            <div>
              <input-modal v-model="contact.job_title" v-on:input="updateContact" placeholder="Job Title" label="Job Title" />
            </div>
            <div>
            <input-modal v-model="contact.email" v-on:input="updateContact"  placeholder="Email" label="Email" />
            </div>
            <div>
            <input-modal v-model="contact.phone" v-on:input="updateContact" placeholder="Phone" label="Phone" />
            </div>
          <div class="" style="padding-bottom:4px;">
           <div class="contact-tags-box">
             <button type="button" class="btn btn-box-tool btn-default btn-sm" v-for="(tag, index) in tags" style="margin: 2px;" v-on:click="removeTag(index);">
               {{tag.name}}
               <i class="fa fa-fw fa-close"></i>
             </button>
             <button type="button" class="btn btn-link" v-on:click="openTagsWindow()">
               <i class="fa fa-fw fa-plus"></i>Add
             </button>
          </div>
          <modal title="Tags" large :show.sync="openTagModal">
            <div slot="modal-body" class="modal-body">
            <v-select
              multiple
              label="name"
              v-model="chooseTags"
              :options="availableTags"
              :pushTags="true"
              :taggable="true"
              :placeholder="Tags"
              :createOption='addNewTag'
             ></v-select>
            </div>
            <div slot="modal-footer" class="modal-footer">
             <button type="button" class="btn btn-success" v-on:click="saveChangesTag" >Save changes</button>
            </div>
          </modal>

          </div>
          <inline-text-edit v-model="contact.description" v-on:input="updateContact" placeholder="Description" ></inline-text-edit>
      </div><!-- /.box-body -->
    </div><!-- /.box -->

</template>

<script>
Vue.use(VueResource);
import {Socket, Presence} from 'phoenix';

import InlineEdit from '../inline-common-edit.vue';
import InlineTextEdit from '../inline-textedit.vue';
import nameInputModal from '../shared/name-input-modal.vue';
import inputModal from '../shared/input-modal.vue';

export default {
  props: [
    'contact',
    'tags'
  ],
  data(){
    return {
      availableTags: [],
      openTagModal: false,
      chooseTags: []
    };
  },
  mounted(){

  },
  watch: {

  },
  methods: {
    removeTag(index) {
      this.tags.splice(index, 1);
      this.tagIds = this.tags.map(function(j) { return j.id; });
      this.updateTags();
    },
    addNewTag(input){
      this.$http.post('/api/v2/tag', {
        tags: { name: input }
      }).then(resp => {
      });

      return { id: input, name: input };
    },
    saveChangesTag(){
      this.tagIds = this.chooseTags.map(function(j) { return j.id; });
      this.tags = this.chooseTags.map(function(j) { return {id: j.id, name: j.name };  });
      this.updateTags();
      this.openTagModal = false;
    },
    openTagsWindow(){

      this.chooseTags = this.tags.map(function(j) { return {id: j.id, name: j.name }; });
      this.getTags();
      this.openTagModal = true;
    },
    getTags() {
      this.$http.get('/api/v2/tag').then(resp => {
        this.availableTags = resp.data.data;
      });
    },

    updateTags() {
      if (this.tagIds.length === 0) {
        var url = '/api/v2/contact/' + this.contact.id + '/utags';
        this.$http.put(url, { companyId: this.contact.company_id } );
      } else {
        var url = '/api/v2/contact/' + this.contact.id + '/update_tags';
        this.$http.put(url,
                           { tags: this.tagIds, companyId: this.contact.company_id }
                          );
      }
    },
    updateContact: function(){
      var url = '/api/v2/contact/' + this.contact.id;
      this.$http.put(url, { contact: this.contact } );
    },
    nameInput: function(data) {
      this.contact.first_name = data.firstName;
      this.contact.last_name = data.lastName;
      this.updateContact();
    }
  },
  components: {
    'inline-edit': InlineEdit,
    'inline-text-edit': InlineTextEdit,
    'v-select': vSelect.VueSelect,
    'modal': VueStrap.modal,
    'name-input-modal': nameInputModal,
    'input-modal': inputModal
  }
};
</script>
