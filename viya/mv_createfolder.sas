/**
  @file mv_createfolder.sas
  @brief Creates a viya folder if that foloder does not already exist
  @details Expects oauth token in a global macro variable (default
    ACCESS_TOKEN).

    options mprint;
    %mv_createfolder(path=/Public)


  @param path= The full path of the folder to be created
  @param access_token_var= The global macro variable to contain the access token
  @param grant_type= valid values are "password" or "authorization_code" (unquoted).
    The default is authorization_code.


  @version VIYA V.03.04
  @author Allan Bowe
  @source https://github.com/Boemska/macrocore

  <h4> Dependencies </h4>
  @li mf_abort.sas
  @li mf_getuniquefileref.sas
  @li mf_getuniquelibref.sas
  @li mf_isblank.sas

**/

%macro mv_createfolder(path=
    ,access_token_var=ACCESS_TOKEN
    ,grant_type=authorization_code
  );

%mf_abort(iftrue=(%mf_isblank(&path)=1)
  ,mac=&sysmacroname
  ,msg=%str(path value must be provided)
)
%mf_abort(iftrue=(%length(&path)=1)
  ,mac=&sysmacroname
  ,msg=%str(path value must be provided)
)

%mf_abort(iftrue=(&grant_type ne authorization_code and &grant_type ne password)
  ,mac=&sysmacroname
  ,msg=%str(Invalid value for grant_type: &grant_type)
)

options noquotelenmax;

%local subfolder_cnt; /* determine the number of subfolders */
%let subfolder_cnt=%sysfunc(countw(&path,/));

%local href; /* resource address (none for root) */
%let href="/folders/folders?parentFolderUri=/folders/folders/none";

%local x newpath subfolder;
%do x=1 %to &subfolder_cnt;
  %let subfolder=%scan(&path,&x,%str(/));
  %let newpath=&newpath/&subfolder;

  %local fname1;
  %let fname1=%mf_getuniquefileref();

  %put &sysmacroname checking to see if &newpath exists;
  proc http method='GET' out=&fname1
      url="http://localhost/folders/folders/@item?path=&newpath";
      headers "Authorization"="Bearer &&&access_token_var";
  run;
  data _null_;infile &fname1;input;putlog _infile_;run;
  %local libref1;
  %let libref1=%mf_getuniquelibref();
  libname &libref1 JSON fileref=&fname1;
  %mf_abort(iftrue=(&SYS_PROCHTTP_STATUS_CODE ne 200 and &SYS_PROCHTTP_STATUS_CODE ne 404)
    ,mac=&sysmacroname
    ,msg=%str(&SYS_PROCHTTP_STATUS_CODE &SYS_PROCHTTP_STATUS_PHRASE)
  )
  %if &SYS_PROCHTTP_STATUS_CODE=200 %then %do;
    %put &sysmacroname &newpath exists so grab the follow on link ;
    data _null_;
      set &libref1..links;
      if rel='createChild' then
        call symputx('href',quote(trim(href)),'l');
    run;
  %end;
  %else %if &SYS_PROCHTTP_STATUS_CODE=404 %then %do;
    %put &sysmacroname &newpath not found - creating it now;
    %local fname2;
    %let fname2=%mf_getuniquefileref();
    data _null_;
      length json $1000;
      json=cats("'"
        ,'{"name":'
        ,quote(trim(symget('subfolder')))
        ,',"description":'
        ,quote("&subfolder, created by &sysmacroname")
        ,',"type":"folder"}'
        ,"'"
      );
      call symputx('json',json,'l');
    run;

    proc http method='POST'
        in=&json
        out=&fname2
        url=%unquote(%superq(href));
        headers "Authorization"="Bearer &&&access_token_var"
                'Content-Type'='application/vnd.sas.content.folder+json'
                'Accept'='application/vnd.sas.content.folder+json';
    run;
    %put &=SYS_PROCHTTP_STATUS_CODE;
    %put &=SYS_PROCHTTP_STATUS_PHRASE;
    data _null_;infile &fname2;input;putlog _infile_;run;
    %mf_abort(iftrue=(&SYS_PROCHTTP_STATUS_CODE ne 201)
      ,mac=&sysmacroname
      ,msg=%str(&SYS_PROCHTTP_STATUS_CODE &SYS_PROCHTTP_STATUS_PHRASE)
    )
    %local libref2;
    %let libref2=%mf_getuniquelibref();
    libname &libref2 JSON fileref=&fname2;
    %put &sysmacroname &newpath now created. Grabbing the follow on link ;
    data _null_;
      set &libref2..links;
      if rel='createChild' then
        call symputx('href',quote(trim(href)),'l');
    run;

    libname &libref2 clear;
    filename &fname2 clear;
  %end;
  filename &fname1 clear;
  libname &libref1 clear;
%end;
%mend;