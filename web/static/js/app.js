// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import "bootstrap-datepicker"
import icheck from "./adminlte/plugins/iCheck/icheck.min"
import slimscroll from "./adminlte/plugins/slimScroll/jquery.slimscroll.min"
import fastclick from "./adminlte/plugins/fastclick/fastclick"
import adminlte from "./adminlte/dist/js/app.min"

import socket from "./socket"
import { Activity } from "./activity"
import inline_edit from "./inline_edit"
import board_add from "./board_add"
import contact_add from "./contact_add"
import { ContactEdit } from "./contact_edit"
import contact_live from "./contact_live"
import { Pipeline } from "./opportunity_pipeline"

export var App = {
  activity_init: function(){
    Activity.start()
  },
  pipeline_init: function(){
    Pipeline.start()
  },
  contact_edit_init: function(user_id, company_id, contact_id, organization_id, opportunity_id, opportunity_contact_ids, tag_ids){
    ContactEdit.start(user_id, company_id, contact_id, organization_id, opportunity_id, opportunity_contact_ids, tag_ids);
  },
  contact_socket_init: function(contact_id){
    contact_live.init(socket, contact_id );
  }
}

import ContactAppEdit from "../components/contacts/edit.vue";


if ($("#contact-app-edit").length > 0){
    new Vue({
        el: "#contact-app-edit",
        components: {
            'contact-app-edit' : ContactAppEdit
        }
    });
};


if ($("#opportunity_pipeline").length > 0){
  App.pipeline_init();
}
