/**
  @file
  @brief Create a Web Ready Stored Process
  @details This macro creates a Type 2 Stored Process with the macropeople h54s
    adapter (development / file upload version) included as pre-code.

    The adapter code is loaded direct from github, so internet access is a
    currently a dependency (feel free to submit a PR to provide a fileref
    based approach).

    Usage:

      * compile macros ;
      filename mc url "https://raw.githubusercontent.com/macropeople/macrocore/master/macrocore.sas";
      %inc mc;

      * parmcards lets us write to a text file from open code ;
      filename ft15f001 "%sysfunc(pathname(work))/somefile.sas";
parmcards4;
      * enter stored process code below ;
      proc sql;
      create table outdataset as
        select * from sashelp.class;

      * output macros for every dataset to send back ;
      %bafheader()
      %bafoutdataset(forJS,work,outdataset)
      %baffooter()
;;;;

      * create the stored process ;
      %mm_createwebservice(service=MyNewSTP
        ,role=common
        ,project=/User Folders/&sysuserid/My Folder/myProj
        ,source=%sysfunc(pathname(work))/somefile.sas
      )


  <h4> Dependencies </h4>
  @li mm_createstp.sas
  @li mf_getuser.sas


  @param project= The metadata project directory root
  @param role= The name of the role (subfolder) within the project
  @param service= Stored Process name.  Avoid spaces - testing has shown that
    the check to avoid creating multiple STPs in the same folder with the same
    name does not work when the name contains spaces.
  @param desc= Service description (optional)
  @param source= /the/full/path/name.ext of the sas program to load
  @param precode= /the/full/path/name.ext of any precode to insert.
  @param server= The server which will run the STP.  Server name or uri is fine.
  @param mDebug= set to 1 to show debug messages in the log

  @version 9.2
  @author Allan Bowe

**/

%macro mm_createwebservice(
     project=/User Folders/sasdemo
    ,role=common
    ,service=myFirstWebService
    ,desc=This stp was created automatically by the mm_createwebservice macro
    ,source=
    ,precode=
    ,mDebug=0
    ,server=SASApp
    ,adapter=deprecated
)/*/STORE SOURCE*/;

%if &syscc ge 4 %then %do;
  %put &=syscc;
  %return;
%end;

%local mD;
%if &mDebug=1 %then %let mD=;
%else %let mD=%str(*);
%&mD.put Executing mm_createwebservice.sas;
%&mD.put _local_;

%local work tmpfile;
%let work=%sysfunc(pathname(work));
%let tmpfile=__mm_createwebservice.temp;

/**
 * Add webout macro
 * These put statements are auto generated - to change the macro, change the
 * source (mm_webout) and run `build.py`
 */
data _null_;
  file "&work/&tmpfile" lrecl=3000 mod;
  put "/* Created on %sysfunc(today(),datetime19.) by %mf_getuser() */";
/* WEBOUT BEGIN */


/* WEBOUT END */
  put '%webout(OPEN)';
run;

/* add precode if provided */
%if %length(&precode)>0 %then %do;
  data _null_;
    file "&work/&tmpfile" lrecl=3000 mod;
    infile "&precode";
    input;
    put _infile_;
  run;
%end;

/* add the SAS program */
data _null_;
  file "&work/&tmpfile" lrecl=3000 mod;
  infile "&source";
  input;
  put _infile_;
run;

/* create the project folder if not already there */
%mm_createfolder(path=&project)
%if &syscc ge 4 %then %return;

/* create the role folder if not already there */
%mm_createfolder(path=&project/&role)
%if &syscc ge 4 %then %return;

/* create the web service */
%mm_createstp(stpname=&service
  ,filename=&tmpfile
  ,directory=&work
  ,tree=&project/&role
  ,stpdesc=&desc
  ,mDebug=&mdebug
  ,server=&server
  ,stptype=2)

%mend;