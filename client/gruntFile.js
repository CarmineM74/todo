module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-compass');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-karma');
  grunt.loadNpmTasks('grunt-html2js');
  grunt.loadNpmTasks('grunt-usemin');
  grunt.loadNpmTasks('grunt-rev');

  // Default tasks
  grunt.registerTask('default',['build','karma:unit']);
  grunt.registerTask('build',['clean','html2js','concat:index','useminPrepare','coffee','compass:dist','copy:styles','copy:fonts','copy:dist','cssmin','usemin']);

  // Print a timestamp while watching
  grunt.registerTask('timestamp',function(){
    grunt.log.subhead(Date());
  });

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    distdir: 'dist',
    banner: '/* <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %>\n' +
            ' * Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author %>;\n' + 
            ' * Licensed <%= _.pluck(pkg.licenses,"type").join(", ") %>\n' + 
            ' */\n',
    src: {
      tpl: {
        app: ['src/app/**/*.tpl.html'],
        common: ['src/common/**/*.tpl.html']
      },
      coffeeTpl: ['<%= distdir %>/templates/**/*.coffee']
    },
    clean: ['<%= distdir %>', '.tmp'],
    html2js: {
      app: {
        options: {
          base: 'src/app',
          target: 'coffee'
        },
        src: ['<%= src.tpl.app %>'],
        dest: '.tmp/templates/app.coffee',
        module: 'templates.coffee'
      },
      common: {
        options: {
          base: 'src/common',
          target: 'coffee'
        },
        src: ['<%= src.tpl.common %>'],
        dest: '.tmp/templates/common.coffee',
        module: 'templates.common'
      }
    },
    concat: {
      index: {
        src: 'src/index.html',
        dest: '<%= distdir %>/index.html',
        options: { process: true }
      }
    },
    useminPrepare: {
      options: {
        dest: '<%= distdir %>'
      },
      html: 'src/index.html'
    },
    usemin: {
      html: '<%= distdir %>/index.html'
    },
    coffee: {
      dist: {
        options: {
          sourceMap: true
        },
        src: ['src/app/**/*.coffee', '.tmp/templates/**/*.coffee'],
        dest: '.tmp/<%= pkg.name %>.js'
      }
    },
    compass: {
      options: {
        sassDir: 'src/compass',
        cssDir: '.tmp/styles',
        imagesDir: 'src/images',
        generatedImagesDir: '.tmp/images/generated',
        javascriptsDir: 'src/app',
        fontsDir: 'src/compass/fonts',
        importPath: 'src/bower_components',
        httpImagesPath: '/images',
        httpGeneratedImagesPath: '/images/generated',
        httpFontsPath: '/styles/fonts',
        relativeAssets: false
      },
      dist: {}
    },
    copy: {
      dist: {
        files: [{expand: true, cwd: '.tmp', src: '*.js', dest: '<%= distdir %>' }]
      },
      styles: {
        expand: true,
        cwd: '.tmp/styles',
        src: '{,*/}*.css',
        dest: '<%= distdir %>/styles'
      },
      fonts: {
        expand: true,
        cwd: 'src/compass',
        src: 'fonts/{,*/}*',
        dest: '<%= distdir %>'
      }
    }
  });
}
