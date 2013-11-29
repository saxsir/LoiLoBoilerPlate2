LIVERELOAD_PORT = 35729
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

module.exports = (grunt) ->
  'use strict'
  # パッケージ全読み込み
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  # ディレクトリ説明
  config =
    app: 'app' #開発ディレクトリ
    build: 'build' #未圧縮（デバッグ用）
    dist: 'dist' #デプロイ用

  # タスク定義
  grunt.initConfig
    # ディレクトリ設定
    config: config
    dir:
      app:
        common: '<%= config.app %>/common'
        ja: '<%= config.app %>/ja'
        en: '<%= config.app %>/en'
      build:
        common: '<%= config.build %>/common'
        ja: '<%= config.build %>/ja'
        en: '<%= config.build %>/en'
      dist:
        ja: '<%= config.dist %>/ja'
        en: '<%= config.dist %>/en'

    # タスク定義
    # jadeコンパイル
    jade:
      compile:
        options:
          pretty: true #整形してアウトプット
          data: (dest, src) -> #destが生成するhtml, srcが参照元jadeファイル
            langFile = ''
            if /\/ja\/index.jade/.test src
              langFile = './app/ja/data/index.json'
            else if /\/en\/index.jade/.test src
              langFile = './app/en/data/index.json'

            require langFile

        files:
          '<%= dir.build.ja %>/index.html': '<%= dir.app.ja %>/index.jade'
          '<%= dir.build.en %>/index.html': '<%= dir.app.en %>/index.jade'

    # stylusコンパイル
    stylus:
      compile:
        options:
          compress: false #圧縮しない
        files:
          '<%= dir.build.common %>/styles/common.css': ['<%= dir.app.common %>/stylus/*.styl']
          '<%= dir.build.ja %>/styles/main.css': ['<%= dir.app.ja %>/stylus/main.styl']
          '<%= dir.build.en %>/styles/main.css': ['<%= dir.app.en %>/stylus/main.styl']

    # coffeeコンパイル
    coffee:
      options:
        bare: false #カプセル化する?
        sourceMap: true
      common:
        expand: true
        cwd: '<%= dir.app.common %>/coffee'
        src: ['*.coffee']
        dest: '<%= dir.build.common %>/scripts'
        ext: '.js'
      js:
        expand: true
        cwd: '<%= dir.app.ja %>/coffee'
        src: ['*.coffee']
        dest: '<%= dir.build.ja %>/scripts'
        ext: '.js'
      en:
        expand: true
        cwd: '<%= dir.app.en %>/coffee'
        src: ['*.coffee']
        dest: '<%= dir.build.en %>/scripts'
        ext: '.js'

    # 画像コピー
    copy:
      images: 
        files: [
          expand: true
          cwd: '<%= dir.app.common %>/images/'
          src: '**'
          dest: "<%= dir.build.common %>/images/"
          filter: "isFile"
        ,
          expand: true
          cwd: '<%= dir.app.ja %>/images/'
          src: '**'
          dest: "<%= dir.build.ja %>/images/"
          filter: "isFile"
        ,
          expand: true
          cwd: '<%= dir.app.en %>/images/'
          src: '**'
          dest: "<%= dir.build.en %>/images/"
          filter: "isFile"
        ]
      others:
        expand: true
        cwd: '<%= config.app %>/'
        src: ['favicon.ico', '.htaccess']
        dest: '<%= config.build %>/'
      bower:
        expand: true
        cwd: 'bower_components/'
        src: [
          'angular/angular.min.js'
          'angular/angular.min.js.map'
        ]
        dest: '<%= dir.build.common %>/scripts/libs/'

    # ファイル変更監視
    watch:
      livereload:
        options:
            livereload: LIVERELOAD_PORT
        files: ['<%= config.build %>/**/*']
      jade:
        files: ['<%= config.app %>/**/*.jade']
        tasks: ['jade']
      stylus:
        files: ['<%= config.app %>/**/*.styl']
        tasks: ['stylus']
      coffee:
        files: ['<%= config.app %>/**/*.coffee']
        tasks: ['coffee']
      images:
        files: ['<%= config.app %>/**/*.png', '<%= config.app %>/**/*.jpg']
        tasks: ['copy:images']

    # サーバー立てる
    connect:
      options:
        port: 9000
        hostname: "localhost"

      livereload:
        options:
          middleware: (connect) ->
            [require("connect-livereload")(port: LIVERELOAD_PORT), mountFolder(connect, config.build)]

    # ブラウザ開く
    open:
      server:
        path: "http://localhost:<%= connect.options.port %>"


  # タスク登録
  grunt.registerTask 'compile', ['jade', 'stylus', 'coffee']
  grunt.registerTask 'default', ['compile', 'copy', 'connect', 'open', 'watch']



