// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in 'brunch-config.js'.
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
import "jquery-ui"
import moment from 'moment';

// Import local files
//
// Local files can be imported directly using relative
// paths './socket' or full ones 'web/static/js/socket'.
import 'bootstrap-datepicker';
import icheck from './adminlte/plugins/iCheck/icheck.min';
import slimscroll from './adminlte/plugins/slimScroll/jquery.slimscroll.min';
import fastclick from './adminlte/plugins/fastclick/fastclick';
import adminlte from './adminlte/dist/js/app.min';

import socket from './socket';

import { Activity } from './activity';
import inlineEdit from './inline_edit';
import boardAdd from './board_add';
import boardColumnAdd from './board_column_add';
import contactAdd from './contact_add';
import contactLive from './contact_live';
import { Pipeline } from './opportunity_pipeline';
import { BoardColumnPipeline } from './board_column_pipeline';
import contactImport from './contact_import';
import blueimpFileUpload from './blueimp_file_upload';

export var App = {
  activityInit: function(){
    Activity.start();
  },
  pipelineInit: function(){
    Pipeline.start();
    BoardColumnPipeline.start();
  },
  contactSocketInit: function(contactId){
    contactLive.init(socket, contactId );
  }
};

import elementLang from 'element-ui/lib/locale/lang/en';
import elementLocale from 'element-ui/lib/locale';
elementLocale.use(elementLang);

Vue.use(require('vue-moment-jalaali'));
Vue.use(VueResource);
Vue.use(VueResourceCaseConverter);

import ContactAppEdit from "../components/contacts/edit.vue";


if ($("#contact-app-edit").length > 0){
    new Vue({
        el: "#contact-app-edit",
        components: {
            'contact-app-edit' : ContactAppEdit
        }
    });
};


if (
    ($("#opportunity_pipeline").length > 0) ||
        ($("[data-pipeline_init]").length > 0)
){
  App.pipelineInit();
}
