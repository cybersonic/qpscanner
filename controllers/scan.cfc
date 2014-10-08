component
{
	function init(fw){variables.fw=arguments.fw;}


	function go(rc)
	{
		if ( NOT StructKeyExists(rc,'Config') )
			rc.Config = "default";

		if ( NOT StructKeyExists(rc,'Instance') )
			rc.Instance = createUuid();

		if ( NOT StructKeyExists(rc,'OutputFormat') )
			rc.OutputFormat = 'html';

		rc.ScanData = Application.Cfcs.Settings.read
			( ConfigId  : rc.Config
			, Format    : 'Struct'
			, Overrides : rc
			);

		Request.Scanner = Application.Cfcs.Scanner.init( ArgumentCollection = rc.ScanData );

		rc.ScanResults = Request.Scanner.go();

		Session.Instance[rc.Instance] =
			{ Settings = rc.ScanData
			, Results  = rc.ScanResults
			, TimeRun  = Now()
			};


		//Now save the reports

		Summary = new Summary();
		Report = new Report(summary=Summary);

		Report.setMatches(rc.ScanResults);

		
		Summary.setpath(rc.ScanData.StartingDir);
		//Summary.setfilesToCheck(rc.ScanData);
		Summary.settermsToCheck(rc.ScanData.ClientScopes);
		//Summary.setblockToCheck(rc.ScanData);
		Summary.setnumberOfMatches(rc.ScanResults.info.totals.alertcount);
		Summary.setnumberOfFiles(rc.ScanResults.info.totals.riskfilecount);
		Summary.setnumberOfQueries(rc.ScanResults.info.totals.querycount);
		Summary.setscanTimetaken(rc.ScanResults.info.totals.time);
		Summary.setscanDate(Now());

	

		Summary.setextraData(rc.ScanData); //Any extra data you want to use
		Summary.setType("SQLi");
		
		Report.save("/sqlireports/");

		fw.setView('results.#rc.OutputFormat#');

		request.layout = rc.OutputFormat EQ 'html';

		rc.Title = 'Scan Results';
	}


}