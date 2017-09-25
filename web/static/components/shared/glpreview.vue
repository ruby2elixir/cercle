<template>
  <div class='attachment-backdrop' v-if="showPreivew">
    <div class='attachment-preview'>
      <div class='attachment-header'>
        <a class='close' @click.stop="closePreview" href='#'><i class='fa fa-times'></i></a>
      </div>
      <div class='attachment-body'>
        <div class="text-center" v-if="attachment">
          <img :src="attachment.attachmentUrl" v-if="isImage" />
          <div class="no-preview" v-else>No preview</div>
        </div>
      </div>
      <div class='attachment-footer'></div>
    </div>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        showPreivew: false,
        attachment: {}
      };
    },
    components: {
    },
    computed: {
      isImage() {
        if(this.attachment.attachmentUrl) {
          let ext = this.attachment.attachmentUrl.split('?')[0].split('.').reverse()[0].toLocaleLowerCase();
          return ['png', 'gif', 'bmp', 'jpg', 'jpeg'].indexOf(ext)>=0;
        } else {
          return false;
        }
      }
    },
    methods: {
      closePreview() {
        this.showPreivew = false;
      }
    },
    mounted() {
      let vm = this;
      vm.$root.$on('esc-keyup', () => { this.closePreview(); });
      vm.$glAttachmentPreview.$on('open', function(options){
        vm.attachment = options['data']['attachment'];
        vm.showPreivew = true;
      });
    }
  };
</script>

<style lang="sass">
  .attachment-backdrop {
    position: fixed;
    top: 0;
    left:0;
    bottom:0;
    right:0;
    background-color: rgba(0,0,0,0.5);
    z-index: 10000;

    .attachment-preview {
      .attachment-header {
        height: 50px;
        position: absolute;
        top:0;
        left: 0;
        right: 0;
        z-index: 1;

        .close {
          color: #fff;
          opacity: 1;
          margin: 10px;
        }
      }

      .attachment-body {
        position: absolute;
        top: 0;
        left:0;
        bottom:0;
        right:0;
        overflow-y: auto;
        text-align: center;
        padding: 50px 0;

        .no-preview {
          color: #fff;
          font-weight: bold;
          padding-top: 250px;
          font-size: 20px;
        }
      }

      .attachment-footer {
        height: 50px;
        position: absolute;
        bottom:0;
        left: 0;
        right: 0;
      }
    }
  }
</style>
