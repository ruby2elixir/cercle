<template>
  <div class="tab-pane active" id="control-sidebar-home-tab" >
    <h3 class="control-sidebar-heading">Recent Activity</h3>
    <ul class="control-sidebar-menu">
      <li  v-for="item in items">
        <a href="#">
          <img :src="item.profile_image_url" style="max-width:40px;border-radius:40px;float:left;" />
          <div class="menu-info" style="margin-left:55px;">
            <h4 class="control-sidebar-subheading" style="font-size:16px;">
              <span style="font-weight:600;">{{item.event_name}}</span>
              <div>
                {{item.content}}
              </div>
            </h4>
          </div>
        </a>
      </li>
    </ul>
    <!-- /.control-sidebar-menu -->
  </div>
</template>
<script>
    import {Socket, Presence} from 'phoenix';

export default {
      props: ['board_id'],
      data() {
        return {
          channel: null,
          items: [ ]
        };
      },
      components: {

      },
      methods: {
        initConn() {
          localStorage.setItem('auth_token', document.querySelector('meta[name="guardian_token"]').content);
          Vue.http.headers.common['Authorization'] = 'Bearer ' + localStorage.getItem('auth_token');

          this.socket = new Socket('/socket', {params: { token: localStorage.getItem('auth_token') }});
          this.socket.connect();
          this.channel = this.socket.channel('board:' + this.board_id, {});
          this.channel.join()
                .receive('ok', resp => { this.channel.push('get'); })
                .receive('error', resp => { console.log('Unable to join', resp); });

          this.channel.on('activities', payload => {
            this.items = payload.recent;
          });

          this.channel.on('timeline_event:created', payload => {
            this.items.unshift(payload);
            console.log('event:added', payload);
          });

        }
      },
      mounted() {
        this.initConn();
      }
};
  </script>
<style lang="sass">

</style>
