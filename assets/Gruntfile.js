module.exports = function( grunt ) {

	grunt.loadNpmTasks( 'grunt-contrib-clean' );
	grunt.loadNpmTasks( 'grunt-contrib-rename' );
	grunt.loadNpmTasks( 'grunt-contrib-uglify' );
	grunt.loadNpmTasks( 'grunt-contrib-watch' );
	grunt.loadNpmTasks( 'grunt-rev' );

	grunt.registerTask( 'default', [ 'uglify', 'clean', 'rev', 'rename' ] );

	grunt.initConfig( {
		uglify: {
			options:{
				  sourceMap     : true
				, sourceMapName : function( dest ){
					var parts = dest.split( "/" );
					parts[ parts.length-1 ] = parts[ parts.length-1 ].replace( /\.js$/, ".map" );
					return parts.join( "/" );
				 }
			},
			specific:{
				files: [{
					expand  : true,
					cwd     : "js/admin/specific/",
					src     : ["**/*.js", "!**/*.min.js" ],
					dest    : "js/admin/specific/",
					ext     : ".min.js",
					rename  : function( dest, src ){
						var pathSplit = src.split( '/' );

						pathSplit[ pathSplit.length-1 ] = "_" + pathSplit[ pathSplit.length-2 ] + ".min.js";

						return dest + pathSplit.join( "/" );
					}
				}]
			}
		},

		clean: {
			all : {
				files : [{
					  src    : "js/**/_*.min.js"
					, filter : function( src ){ return src.match(/[\/\\]_[a-f0-9]{8}\./) !== null; }
				}]
			}
		},

		rev: {
			options: {
				algorithm : 'md5',
				length    : 8
			},
			all: {
				files : [
					  { src : "js/**/_*.min.js"  }
				]
			}
		},

		rename: {
			assets: {
				expand : true,
				cwd    : '',
				src    : '**/*._*.min.{js,css}',
				dest   : '',
				rename : function( dest, src ){
					var pathSplit = src.split( '/' );

					pathSplit[ pathSplit.length-1 ] = "_" + pathSplit[ pathSplit.length-1 ].replace( /\._/, "." );

					return dest + pathSplit.join( "/" );
				}
			}
		},

		watch: {
			all : {
				files : [ "js/**/*.js", "!js/**/*.min.js" ],
				tasks : [ "default" ]
			}
		}
	} );
};