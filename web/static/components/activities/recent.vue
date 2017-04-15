<template>
  <div class="tab-pane active" id="control-sidebar-home-tab" >
    <h3 class="control-sidebar-heading">Recent Activity</h3>
    <ul class="control-sidebar-menu">
      <li  v-for="item in items">
        <a href="#">
          <img :src="item.profile_image" style="max-width:40px;border-radius:40px;float:left;" />
          <div class="menu-info" style="margin-left:55px;">
            <h4 class="control-sidebar-subheading" style="font-size:16px;">
              <span style="font-weight:600;">{{item.name}}</span>
              <div>
                {{item.event}}
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
    data() {
        return {
            channel: null,
            items: [
                {
                    profile_image: "https://cercle-prod.s3.amazonaws.com/uploads/users/profile_images/12/small_5.png",
                    name: 'Antoine Herzog',
                    event: 'mentioned you on the contact  Bello Mama'
                },
                {
                    profile_image: "https://cercle-prod.s3.amazonaws.com/uploads/users/profile_images/12/small_5.png",
                    name: 'Antoine Herzog',
                    event: 'mentioned you on the contact  Bello Mama'
                },
                {
                    profile_image: "https://cercle-prod.s3.amazonaws.com/uploads/users/profile_images/12/small_5.png",
                    name: 'Antoine Herzog',
                    event: 'mentioned you on the contact  Bello Mama'
                },
                {
                    profile_image: "https://cercle-prod.s3.amazonaws.com/uploads/users/profile_images/12/small_5.png",
                    name: 'Antoine Herzog',
                    event: 'mentioned you on the contact  Bello Mama'
                }
            ]
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
            this.channel = this.socket.channel('activities', {});
            this.channel.join()
                .receive('ok', resp => {  })
                .receive('error', resp => { console.log('Unable to join', resp); });

            this.channel.on('event:added', payload => {
                console.log('event:added', payload)
            });

        }
    },
    mounted() {
        this.initConn()
    }
};
  </script>
<style lang="sass">

</style>
