<template>
  <div class="email-show">
    <p>From: {{ email.from_email }}</p>
    <p>To: {{ email.to_email }}</p>
    <p>Subject: {{ email.subject }}</p>

    <p v-html="email.body"></p>
  </div>
</template>

<script>
export default {
  props: ['email'],
  data() {
    return {
    };
  },
  methods: {
  }
};
</script>

<style>
  .email-show {
    padding: 20px;
  }
</style>
