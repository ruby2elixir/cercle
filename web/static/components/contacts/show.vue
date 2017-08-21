<template>
  <div class="contact-show">
    <div class="row">
      <div class="col-md-12">
        <contact-details :contact="contact" />
      </div>
    </div>
  </div>
</template>

<script>
import ContactDetails from './contact-details.vue';

export default {
  props: ['contact'],
  data() {
    return {
    };
  },
  watch: {
  },
  components: {
    'contact-details': ContactDetails
  },
  methods: {
  }
};
</script>

<style>
  .contact-show {
    padding: 20px;
  }
</style>
