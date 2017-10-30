<template>
  <div class='board-container'>
    <div class='board-header' >
      <h2 style="margin-bottom:20px;font-size:24px;">Create a new board</h2>
    </div>

    <div class='board-form-container' style="min-height:800px;">
      <div class='board-form-content'>
        <div style="margin-bottom:10px;">
          <input type="text">
        </div>

        <Br />
        <div style="font-size:19px;margin-bottom:10px;">Type of board
        </div>
        <div style="font-size:15px;line-height: 30px;">
          <%= radio_button(f, :type_of_card, "0") %>&nbsp;&nbsp;Project Board (to track tasks and manage projects)
          <br />
          <%= radio_button(f, :type_of_card, "1") %>&nbsp;&nbsp;People Board (to track business deals or manage clients)
        </div>
        <Br />
      </div>
      <button class="btn btn-primary" >CREATE</button>
    </div>
  </div>
</div>

</template>
<script>
  export default {
    data() {
      return {};
    }
  };
  </script>
<style lang="sass">
</style>
