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
// to also remove its path from 'config.paths.watched'.
import 'phoenix_html';

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
import selectize from './selectize';
import { Activity } from './activity';
import inlineEdit from './inline_edit';
import boardAdd from './board_add';
import boardColumnAdd from './board_column_add';
import contactAdd from './contact_add';
import { ContactEdit } from './contact_edit';
import contactLive from './contact_live';
import { Pipeline } from './opportunity_pipeline';
import contactImport from './contact_import';
import blueimpFileUpload from './blueimp_file_upload';

export var App = {
  activityInit: function(){
    Activity.start();
  },
  pipelineInit: function(){
    Pipeline.start();
  },
  contactEditInit: function(userId, companyId, contactId, organizationId, opportunityId, opportunityContactIds, tagIds, jwtToken){
    ContactEdit.start(userId, companyId, contactId, organizationId, opportunityId, opportunityContactIds, tagIds, jwtToken);
  },
  contactSocketInit: function(contactId){
    contactLive.init(socket, contactId );
  }
};

