/**
  @file mv_getgroups.sas
  @brief Creates a dataset with a list of viya groups
  @details First, be sure you have an access token (which requires an app token).

  Using the macros here:

      filename mc url
        "https://raw.githubusercontent.com/macropeople/macrocore/master/mc_all.sas";
      %inc mc;

  An administrator needs to set you up with an access code:

      %mv_registerclient(outds=client)

  Navigate to the url from the log (opting in to the groups) and paste the
  access code below:

      %mv_tokenauth(inds=client,code=wKDZYTEPK6)

  Now we can run the macro!

      %mv_getgroups()

  @param access_token_var= The global macro variable to contain the access token
  @param grant_type= valid values are "password" or "authorization_code" (unquoted).
    The default is authorization_code.
  @param outds= The library.dataset to be created that contains the list of groups


  @version VIYA V.03.04
  @author Allan Bowe
  @source https://github.com/macropeople/macrocore

  <h4> Dependencies </h4>
  @li mp_abort.sas
  @li mf_getplatform.sas
  @li mf_getuniquefileref.sas
  @li mf_getuniquelibref.sas

**/

%macro mv_getgroups(access_token_var=ACCESS_TOKEN
    ,grant_type=detect
    ,outds=work.viyagroups
  );
%local oauth_bearer;
%if &grant_type=detect %then %do;
  %if %mf_getplatform(SASSTUDIO) ge 5 %then %do;
    %let grant_type=sas_services;
    %let &access_token_var=;
    %let oauth_bearer=oauth_bearer=sas_services;
  %end;
  %else %if %symexist(&access_token_var) %then %let grant_type=authorization_code;
  %else %let grant_type=password;
%end;
%put &sysmacroname: grant_type=&grant_type;
%mp_abort(iftrue=(&grant_type ne authorization_code and &grant_type ne password 
    and &grant_type ne sas_services
  )
  ,mac=&sysmacroname
  ,msg=%str(Invalid value for grant_type: &grant_type)
)

options noquotelenmax;

/* fetching folder details for provided path */
%local fname1;
%let fname1=%mf_getuniquefileref();
%let libref1=%mf_getuniquelibref();

proc http method='GET' out=&fname1 &oauth_bearer
  url="http://localhost/identities/groups";
  headers 
  %if &grant_type=authorization_code %then %do;
          "Authorization"="Bearer &&&access_token_var"
  %end;
          "Accept"="application/json";
run;
/*data _null_;infile &fname1;input;putlog _infile_;run;*/
%mp_abort(iftrue=(&SYS_PROCHTTP_STATUS_CODE ne 200)
  ,mac=&sysmacroname
  ,msg=%str(&SYS_PROCHTTP_STATUS_CODE &SYS_PROCHTTP_STATUS_PHRASE)
)
libname &libref1 JSON fileref=&fname1;

data &outds;
  set &libref1..items;
run;



/* clear refs */
filename &fname1 clear;
libname &libref1 clear;

%mend;