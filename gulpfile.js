'use strict';

var path = require('path'),
    gulp = require('gulp'),
    bower = require('gulp-bower');

var config = {
  bowerDir: './bower_components'
}

gulp.task('bower', function() {
  return bower()
    .pipe(gulp.dest(config.bowerDir))
});

gulp.task('js', function() {
    return gulp.src(config.bowerDir + '/jquery/dist/jquery.js')
        .pipe(gulp.dest('./public/resources/js'));
});
