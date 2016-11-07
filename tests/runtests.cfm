<cfscript>
	processingdirective suppressWhiteSpace=true {
		isCommandLineExecuted = cgi.server_protocol == "CLI/1.0";

		function exitCode( required numeric code ) {
			var exitcodeFile = GetDirectoryFromPath( GetCurrentTemplatePath() ) & "/.exitcode";
			FileWrite( exitcodeFile, code );
		}

		try {
			testbox  = new testbox.system.TestBox( options={}, reporter=( isCommandLineExecuted ? "junit" : "simple" ), directory={
				  recurse  = true
				, mapping  = "tests.unit"
				, filter   = function( required path ){ return true; }
			} );

			results = Trim( testbox.run() );
			if ( isCommandLineExecuted ) {
				resultsFile = GetDirectoryFromPath( GetCurrentTemplatePath() ) & "/testresults.xml";
				FileWrite( resultsFile, results );

				resultObject = testbox.getResult();
				errors       = resultObject.getTotalFail() + resultObject.getTotalError();

				totalDuration = resultObject.getTotalDuration();
				totalSpecs    = resultObject.getTotalSpecs();
				totalPass     = resultObject.getTotalPass();
				totalFail     = resultObject.getTotalFail();
				totalError    = resultObject.getTotalError();
				totalSkipped  = resultObject.getTotalSkipped();

				echo( "Tests complete in #NumberFormat( totalDuration )#ms. " );
				if ( errors ) {
					echo( "One or more tests failed or created an error." );
				} else {
					echo( "All tests passed!" );
				}

				echo( Chr( 13 ) & Chr( 10 ) );

				echo( 'Total: #NumberFormat( totalSpecs )#. Pass: #NumberFormat( totalPass )#. Fail: #NumberFormat( totalFail )#. Error: #NumberFormat( totalError )#. Skipped: #NumberFormat( totalSkipped )#' );
				echo( Chr( 13 ) & Chr( 10 ) );
				echo( Chr( 13 ) & Chr( 10 ) );

				exitCode( errors ? 1 : 0 );
			} else {
				echo( results );
			}

		} catch ( any e ) {
			if ( isCommandLineExecuted ) {
				echo( "An error occurred running the tests. Message: [#e.message#], Detail: [#e.detail#]" );
				exitCode( 1 );
			} else {
				rethrow;
			}
		}
	}
</cfscript>