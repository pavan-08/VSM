module.exports = function(grunt){
    grunt.initConfig({

        watch: {

            js: {
                files: [
                    'Gruntfile.js',
                    'js/*.js'
                ],
                tasks: ['uglify'],
                option: {
                    livereload: true
                }
            },
            css: {
                files: [
                    'css/sass/*.scss'
                ],
                tasks: ['sass', 'cssmin', 'clean'],
                option: {
                    livereload: true
                }
            }
        },

        uglify: {
            dist: {
                files: {
                    'js/minified/footer.min.js'     : 'js/footer.js',
                    'js/minified/header.min.js'     : 'js/header.js',
                    'js/minified/game.min.js'       : 'js/game.js',
                    'js/minified/dashboard.min.js'  : 'js/dashboard.js',
                    'js/minified/leaderboard.min.js': 'js/leaderboard.js',
                    'js/minified/myshares.min.js'   : 'js/myshares.js',
                    'js/minified/modal.min.js'      : 'js/modal.js',
                    'js/minified/vsmfvjs.min.js'    : 'js/vsmfvjs.js'
                }
            }
        },
        sass: {
            dist: {
                files: {
                    'css/style.css' : 'css/sass/style.scss'
                }
            }
        },

        cssmin: {
            dist: {
                files: {
                    'css/style.min.css' : 'css/style.css'
                }
            }
        },

        clean: {
            dist: {
                src: [
                    'css/style.css'
                ]
            }
        }

    });

    //loading the tasks
    grunt.loadNpmTasks( 'grunt-contrib-watch' );
    grunt.loadNpmTasks( 'grunt-contrib-uglify' );
    grunt.loadNpmTasks( 'grunt-contrib-sass' );
    grunt.loadNpmTasks( 'grunt-contrib-cssmin' );
    grunt.loadNpmTasks( 'grunt-contrib-clean' );

    //registering tasks
    grunt.registerTask('css', ['sass', 'cssmin', 'clean']);
    grunt.registerTask('build',['css','uglify']);
    grunt.registerTask('default', ['build','watch']);

};