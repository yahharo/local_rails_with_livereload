# 設定
setting = require './local_rails_setting.json'
RAILS_URL = setting['RAILS_URL']
RAILS_SRC_PATH = setting['RAILS_SRC_PATH']
PROXY_PATHS = setting['PROXIES']

proxies = []
for path in PROXY_PATHS
  proxies.push({source: path, target: RAILS_URL+path})

# gulp
gulp = require 'gulp'

# package
pkg = require './package.json'

# util
cached = require 'gulp-cached'
changed = require 'gulp-changed'
remember = require 'gulp-remember'
newer = require 'gulp-newer'
webserver = require 'gulp-webserver'
watch = require 'gulp-watch'
plumber = require 'gulp-plumber'
rename = require 'gulp-rename'
sourcemaps = require 'gulp-sourcemaps'
notify = require 'gulp-notify'

# js
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
uglify = require 'gulp-uglify'

# css
sass_ruby = require 'gulp-ruby-sass'
concat = require 'gulp-concat'

# html
ect = require 'gulp-ect'

# error
errorMessage = "Error: <%= error.message %>"

# ファイルの出力先、定数にしておく
DEST_PATH = "public"
ASSET_PATH = DEST_PATH + "/assets"
ASSET_PROJECT_PATH = "/gulp_assets"
DEST_PATH_PROJECT_ASSET = DEST_PATH+ ASSET_PROJECT_PATH
RAILS_COFFEE_PATH = RAILS_SRC_PATH+'/app/assets/javascripts/**/*.coffee'
RAILS_SCSS_DIR = RAILS_SRC_PATH+'/app/assets/stylesheets'
RAILS_PUBLIC_CSS_DIR = RAILS_SRC_PATH+'/public/stylesheets'

# Coffeeのlintとコンパイル
gulp.task 'coffee' ,->
  gulp
    .src [RAILS_COFFEE_PATH]
    .pipe(cached( 'coffee' ))
    .pipe plumber({ errorHandler: notify.onError( errorMessage ) })
    .pipe coffee()
    .pipe rename extname: ''
    .pipe gulp.dest DEST_PATH_PROJECT_ASSET

# ectの生成
gulp.task 'ect' ,->
  gulp
    .src ['src/ect/*.ect']
    .pipe(cached( 'ect' ))
    .pipe ect({data: (fileName,cb) ->
      cb({
        package_name: pkg.name
        project_assets_path: ASSET_PROJECT_PATH
      })
    })
    .pipe gulp.dest DEST_PATH

# *.css.scssのような名前だとgulp-ruby-sassがimportしてくれない。
# 仕方ないので_*.scssの形に変換する
# いずれ不要になるはず
gulp.task 'rename_scss' ,->
  gulp.src [
      RAILS_SCSS_DIR+'/back.css.scss'
    ]
    .pipe rename({
        prefix: "_"
        extname: ""
    })
    .pipe rename({
        extname: ".scss"
    })
    .pipe gulp.dest RAILS_SCSS_DIR

# scssのコンパイル
# application.cssの順序でコンパイル
# 追加する場合はここも追記
# 変更があるファイルだけを再度コンパイルするようにしている
# ただし、mixinとbackは名前のせいで解決できないので
# rename_scssで名前変えてからgulpやり直し
gulp.task 'sass_ruby' ,->
  gulp
    .src [
      RAILS_SCSS_DIR+'/default.css.scss'
      RAILS_SCSS_DIR+'/common.css.scss'
      RAILS_SCSS_DIR+'/layout.css.scss'
      RAILS_SCSS_DIR+'/back.css.scss'
      RAILS_SCSS_DIR+'/admin.css.scss'
      RAILS_SCSS_DIR+'/side.css.scss'
      RAILS_SCSS_DIR+'/parts.css.scss'
      RAILS_SCSS_DIR+'/routine_work.css.scss'
      RAILS_SCSS_DIR+'/hierarchy_selector.css.scss'
      RAILS_SCSS_DIR+'/faq.css.scss'
      RAILS_SCSS_DIR+'/helpdesk.css.scss'
      RAILS_SCSS_DIR+'/hd_form_template.css.scss'
      RAILS_SCSS_DIR+'/helpdesk_search.css.scss'
      RAILS_SCSS_DIR+'/message.css.scss'
      RAILS_SCSS_DIR+'/file_uploader.css.scss'
      RAILS_SCSS_DIR+'/calendar.css.scss'
    ]
    .pipe cached( 'sass_ruby' )
    .pipe plumber({ errorHandler: notify.onError( errorMessage ) })
    .pipe sass_ruby()
    .pipe remember('sass_ruby')
    .pipe concat('application.css')
    .pipe gulp.dest DEST_PATH_PROJECT_ASSET


gulp.task 'css_set' ,->
  gulp
    .src [
      RAILS_PUBLIC_CSS_DIR+'/**/*.css'
    ]
    .pipe cached('css_set')
    .pipe remember('css_set')
    .pipe gulp.dest DEST_PATH+'/stylesheets'

# ローカルサーバの起動とライブリロード
# proxiesに必要なプロキシ郡を設定し、
# ローカルのrailsに任せる
gulp.task 'serve' ,->
  gulp
    .src ['public']
    .pipe webserver({
        livereload: true
        proxies: proxies
    })

# ファイル監視
gulp.task 'watch' ,->
  gulp.watch(RAILS_COFFEE_PATH, ['coffee'])
  gulp.watch(RAILS_SCSS_DIR+'/**/*.scss', ['sass_ruby'])
  gulp.watch('src/ect/**/*.ect', ['ect'])
  gulp.watch(RAILS_PUBLIC_CSS_DIR+'/**/*.css', ['css_set'])


# デフォルトタスク
gulp.task 'default' ,['coffee','rename_scss','sass_ruby','css_set','ect','serve','watch']
