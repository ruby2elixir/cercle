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
import 'phoenix_html';

import moment from 'moment';

// Import local files
//
// Local files can be imported directly using relative
// paths './socket' or full ones 'web/static/js/socket'.

import socket from './socket';
import contactImport from './contact_import';
import blueimpFileUpload from './blueimp_file_upload';
import tagEdit from './tag_edit';
import { directive as onClickOutside } from 'vue-on-click-outside';
import linkify from 'vue-linkify';
import VueRouter from 'vue-router';
Vue.use(VueRouter);
Vue.directive('linkified', linkify);
Vue.directive('on-click-outside', onClickOutside);

var VueTruncate = require('vue-truncate-filter');
Vue.use(VueTruncate);

Vue.filter('formatDate', function(value) {
  if (value) {
    return moment(String(value) + 'Z').format('MM/DD/YYYY');
  }
});

Vue.filter('formatDateTime', function(value, format) {
  let dateFormat = format || 'MM/DD/YYYY hh:mm a';
  if (value) {
    return moment(String(value) + 'Z').format(dateFormat);
  }
});

export var App = {
  activityInit: function(){  },
  contactSocketInit: function(contactId){  }
};

import elementLang from 'element-ui/lib/locale/lang/en';
import elementLocale from 'element-ui/lib/locale';
elementLocale.use(elementLang);

Vue.use(require('vue-moment'));
Vue.use(VueResource);
Vue.use(VueResourceCaseConverter, {
  responseUrlFilter(url) {
    if(/\/api\/v2\//.test(url))
      return true;
    else
      return false;
  }
});
Vue.http.interceptors.push((request, next) => {
  localStorage.setItem('http_req', parseInt(localStorage.getItem('http_req') || 0) + 1 );
  document.querySelector('body').classList.remove('async-ready');
  next((response) => {
    localStorage.setItem('http_req', parseInt(localStorage.getItem('http_req') || 0) - 1 );
    if (parseInt(localStorage.getItem('http_req') || 0) <= 0) {
      document.querySelector('body').classList.add('async-ready');
    }
    return response;
  });
});

import ContactList from '../components/contacts/list.vue';
import ContactSingleNew from '../components/contacts/single_new.vue';
import Board from '../components/boards/board.vue';
import BoardSidebar from '../components/boards/board-sidebar.vue';
import ToggleBoardSidebar from '../components/boards/board-sidebar-toggle.vue';
import BoardNew from '../components/boards/new.vue';
import BoardEdit from '../components/boards/edit.vue';
import BoardList from '../components/boards/list.vue';
import Activities from '../components/activities/list.vue';
import BoardRecentActivities from '../components/boards/recent_timeline_events.vue';
import ArchiveBoard from '../components/boards/archive.vue';
import NotificationApp from '../components/shared/notification.vue';
import GlModalWindow from '../components/shared/glmodal.vue';
import GlAttachmentPreview from '../components/shared/glpreview.vue';
import UserNavBar from '../components/shared/navbar.vue';
import CardPage from '../components/cards/show.vue';

Vue.use(require('vue-autosize'));
const NotificationBus = new Vue();
Object.defineProperty(Vue.prototype, '$notification', {
  get() {
    return NotificationBus;
  }
});

import lodash from 'lodash';
Object.defineProperty(Vue.prototype, '$_', { value: lodash });

const GlobalModalWindow = new Vue();
Object.defineProperty(Vue.prototype, '$glmodal', {
  get() {
    return GlobalModalWindow;
  }
});
const GlobalAttachmentPreview = new Vue();
Object.defineProperty(Vue.prototype, '$glAttachmentPreview', {
  get() {
    return GlobalAttachmentPreview;
  }
});

Vue.mixin( {
  methods: {
    toUserTz: function(value) {
      if (value) {
        return moment(String(value) + 'Z').toDate();
      }
    },
    camelCaseKeys: function(o){
      var newO, origKey, newKey, value;
      if (o instanceof Array) {
        newO = [];
        for (origKey in o) {
          value = o[origKey];
          if (typeof value === 'object') {
            value = this.camelCaseKeys(value);
          }
          newO.push(value);
        }
      } else {
        newO = {};
        for (origKey in o) {
          if (o.hasOwnProperty(origKey)) {
            newKey = origKey.replace(/[\-_\s]+(.)?/g, function(match, chr) {
              return chr ? chr.toUpperCase() : '';
            });
            value = o[origKey];
            if (value !== null && (value.constructor === Object || value.constructor === Array)) {
              value = this.camelCaseKeys(value);
            }
            newO[newKey] = value;
          }
        }
      }
      return newO;
    }
  }
});

const VueCurrentUser = {
  install(Vue, options) {
    localStorage.setItem('auth_token', options['token']);
    Vue.http.headers.common['Authorization'] = 'Bearer ' + localStorage.getItem('auth_token');
    moment.tz.setDefault(options['timeZone']);
    Vue.currentUser =  {
      userId: options['userId'],
      companyId: options['companyId'],
      token: options['token'],
      timeZone: options['timeZone'],
      userImage: options['userImage'],
      eq: function(id) {
        return this.userId === id.toString();
      }
    };
  }
};

window.jwtToken = null;
if (document.querySelector('meta[name="guardian_token"]')) {
  window.jwtToken = document.querySelector('meta[name="guardian_token"]').content;
  Vue.use(VueCurrentUser, {
    userId: document.querySelector('meta[name="user_id"]').content,
    companyId: document.querySelector('meta[name="company_id"]').content,
    token: document.querySelector('meta[name="guardian_token"]').content,
    timeZone: document.querySelector('meta[name="time_zone"]').content,
    userImage: document.querySelector('meta[name="user_image"]').content
  });
}

// Vue apps
if ($('#user-navbar').length > 0) {
  new Vue({
    el: '#user-navbar',
    components: {
      'navbar': UserNavBar
    }
  });
}

if ($('.main-app').length > 0) {
  const routes = [
    {
      path: '/company/:company_id/board',
      component: BoardList,
      name: 'boards',
      meta: { classContainer: 'container boards-page', classWrapper: ' ' }
    },
    {
      path: '/company/:companyId/board/new', component: BoardNew,
      meta: { classContainer: 'container boards-page', classWrapper: ' ' },
      props: true
    },
    {
      path: '/company/:companyId/board/:boardId/edit', component: BoardEdit,
      meta: { classContainer: 'container boards-page', classWrapper: ' ' },
      props: true
    },
    {
      path: '/company/:company_id/contact',
      name: 'contacts',
      component: ContactList,
      meta: { classContainer: 'container contacts-page', classWrapper: ' ' },
      props: true
    },


    {
      path: '/company/:companyId/contact/new',
      component: ContactSingleNew,
      meta: { classContainer: 'container contacts-page', classWrapper: ' ', classPageWrapper: '' },
      props: true
    },

    {
      path: '/company/:company_id/contact/:contactId',
      component: ContactList,
      name: 'contactPage',
      meta: { classContainer: 'container contacts-page', classWrapper: ' ' },
      props: true
    },

    {
      path: '/company/:company_id/activity',
      component: Activities,
      name: 'activities',
      meta: { classContainer: 'container activities-page', classWrapper: ' ' },
      props: true
    },

    {
      path: '/company/:company_id/board/:board_id',
      meta: {
        classContainer: ' ',
        classWrapper: 'board',
        classPageWrapper: 'wrapper_board' },
      components: {
        default: Board,
        'board-sidebar': BoardSidebar,
        'board-sidebar-toggle': ToggleBoardSidebar
      },
      props: {
        default: true,
        'board-sidebar': true,
        'board-sidebar-toggle': false
      }
    },
    {
      path: '/company/:companyId/board/:board_id/card/:cardId',
      name: 'cardPage',
      meta: {
        classContainer: 'board-page card-page',
        classWrapper: 'wrapper_board board',
        classPageWrapper: 'wrapper_board' },
      components: {
        default: Board,
        'board-sidebar': BoardSidebar,
        'board-sidebar-toggle': ToggleBoardSidebar
      },
      props: {
        default: true,
        'board-sidebar': true,
        'board-sidebar-toggle': false

      }
    }
  ];
  const router = new VueRouter({
    mode: 'history',
    routes: routes
  });

  router.beforeEach((to, from, next) => {
    let menuLinks = ['contacts', 'boards', 'activities'];
    if (!document.querySelector('.router-view') && lodash.includes(menuLinks, to.name)) {
      window.location.href = to.path;
    } else { next(); }
  });
  new Vue({
    router: router,
    computed: {
      classPageWrapper() { return this.$route.meta.classPageWrapper;  },
      classContainer() { return this.$route.meta.classContainer || 'container';  },
      classWrapper () { return this.$route.meta.classWrapper; }
    },
    mounted() {
      window.addEventListener('keyup', (event) => {
        if (event.keyCode === 27) { this.$emit('esc-keyup'); }
      });
    }
  }).$mount('.main-app');
}

if ($('#notification-app').length > 0) {
  new Vue({
    el: '#notification-app',
    components: {
      'notification': NotificationApp
    }
  });
}

if ($('#global-modal-window').length > 0) {
  new Vue({
    el: '#global-modal-window',
    components: { 'glmodal': GlModalWindow },
    mounted() {
      window.addEventListener('keyup', (event) => {
        if (event.keyCode === 27) { if(!$('#global-attachment-preview').is(':visible')){this.$emit('esc-keyup');} }
      });
    }

  });
}

if ($('#global-attachment-preview').length > 0) {
  new Vue({
    el: '#global-attachment-preview',
    components: { 'gl-attachment-preview': GlAttachmentPreview },
    mounted() {
      window.addEventListener('keyup', (event) => {
        if (event.keyCode === 27) { this.$emit('esc-keyup'); }
      });
    }
  });
}
// end - Vue apps

// Login page
if ($('#session_time_zone').length > 0) {
  $('#session_time_zone').val(jsTz.determine().name());
}
