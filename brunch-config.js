exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: 'js/app.js',
      order: {
        before: [
          'web/static/vendor/js/bootstrap.min.js'
        ]
      }

      // To use a separate vendor.js bundle, specify two files path
      // https://github.com/brunch/brunch/blob/stable/docs/config.md#files
      // joinTo: {
      //  'js/app.js': /^(web\/static\/js)/,
      //  'js/vendor.js': /^(web\/static\/vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // https://github.com/brunch/brunch/tree/master/docs#concatenation
      // order: {
      //   before: [
      //     'web/static/vendor/js/jquery-2.1.1.js',
      //     'web/static/vendor/js/bootstrap.min.js'
      //   ]
      // }
    },
    stylesheets: {
      joinTo: 'css/app.css',
      order: {
        after: [/^node_modules/]
      }
    },
    templates: {
      joinTo: 'js/app.js'
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to '/web/static/assets'. Files in this directory
    // will be copied to `paths.public`, which is 'priv/static' by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      'web/static',
      'test/static'
    ],

    // Where to compile files to
    public: 'priv/static'
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/(web\/static\/vendor)|node_modules/]
    },
    vue: {
      extractCSS: true,
      out: 'priv/static/css/components.css'
    },
    sass: {
      mode: 'native' // This is the important part!
    }
  },

  modules: {
    autoRequire: {
      'js/app.js': ['web/static/js/app']
    }
  },

  npm: {
    enabled: true,
    globals: {
      $: 'jquery',
      jQuery: 'jquery',
      Vue: 'vue/dist/vue.common.js',
      jsTz: 'jstz',
      vSelect: 'vue-select/dist/vue-select.js',
      VueResource: 'vue-resource',
      VueResourceCaseConverter: 'vue-resource-case-converter',
      VueStrap: 'vue-strap',
      Moment: 'moment-timezone',
      ElementUi: 'element-ui',
      MarkdownIt: 'markdown-it',
      VueAutosize: 'vue-autosize',
      FileUpload: 'vue-upload-component',
      onClickOutside: 'vue-on-click-outside',
      VueDraggable: 'vuedraggable'

    },
    styles: {
      'element-ui':  ['lib/theme-chalk/index.css'],
      'bootstrap': ['dist/css/bootstrap.css']
    },
    // Whitelist the npm deps to be pulled in as front-end assets.
    // All other deps in package.json will be excluded from the bundle.
    whitelist: ['phoenix', 'phoenix_html', 'jquery', 'bootstrap-datepicker',
      'blueimp-file-upload', 'vue-select', 'vue-resource',
      'vue-strap', 'moment', 'element', 'markdown-it', 'vue-autosize', 'vue-on-click-outside']
  }
};
