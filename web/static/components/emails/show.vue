<template>
  <div class="email-show">
    <p>From: {{ email.fromEmail }}</p>
    <p>To: {{ email.to[0] }}</p>
    <p>Date: {{ email.date }}</p>
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
