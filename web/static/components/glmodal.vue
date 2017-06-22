<template>
  <modal :large="largeSize" :small="smallSize" :show="open" v-bind:class="[windowClass]" :backdrop=false>
    <div slot="modal-header" class="modal-header" v-if="!!options.display_header">
      {{options.title}}
      <button type="button" class="close" @click="close()" v-if="options.closed_in_header">
        <span>&times;</span>
      </button>
    </div>
    <span slot="modal-header" v-if="!options.display_header"></span>
    <div slot="modal-body" class="modal-body">
      <button type="button" class="close" @click="close()"  v-if="!options.closed_in_header" >
        <span>&times;</span>
      </button>
      <component keep-alive v-bind:is="view" v-bind="modalData" v-on:close="close()">
      </component>
    </div>
    <span slot="modal-footer"></span>
  </modal>

</template>
<script>
import ContactForm from './contacts/edit.vue';
import NewContact from './contacts/new.vue';
export default {
      data() {
        return {
          windowClass: '',
          open: false,
          modalData: {},
          view: null,
          options: {}
        };
  },
      methods: {
        sizeModal() { return this.options.size || 'large'; },
        close() { this.open = false;  }

      },
      computed: {
        largeSize: function() { return this.sizeModal() === 'large'; },
        smallSize: function() { return this.sizeModal() === 'small'; }

      },
      components: {
        'modal': VueStrap.modal,
        'contact-form': ContactForm,
        'new-contact-form': NewContact
  },
      mounted() {
        let vm = this;
        vm.$glmodal.$on('open', function(options){
          vm.view = options['view'];
          vm.modalData = options['data'];
          vm.windowClass = options['class'];
          vm.options = options;
          vm.open = true;
        });
        vm.$root.$on('esc-keyup', () => { this.open = false; });
  }
};
</script>

<style lang="sass">

</style>
