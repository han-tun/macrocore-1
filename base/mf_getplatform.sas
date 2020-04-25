/**
  @file mf_getplatform
  @brief Returns platform specific variables
  @details Enables platform specific variables to be returned

      %put %mf_getplatform();

    returns:
      SASMETA  (or SASVIYA)

  @param switch the param for which to return a platform specific variable

  <h4> Dependencies </h4>
  @li mf_mval.sas

  @version 9.4 / 3.4
  @author Allan Bowe
**/

%macro mf_getplatform(switch
)/*/STORE SOURCE*/;
%local a b c;
%if &switch.NONE=NONE %then %do;
  %if %symexist(sysprocessmode) %then %do;
    %if "&sysprocessmode"="SAS Object Server" 
    or "&sysprocessmode"= "SAS Compute Server" %then %do;
        SASVIYA
    %end;
    %else %if "&sysprocessmode"="SAS Stored Process Server" %then %do;
      SASMETA
      %return;
    %end;
    %else %do;
      SAS
      %return;
    %end;
  %end;
  %else %if %symexist(_metaport) %then %do;
    SASMETA
    %return;
  %end;
  %else %do;
    SAS
    %return;
  %end;
%end;
%else %if &switch=SASSTUDIO %then %do;
  /* return the version of SAS Studio else 0 */
  %if %mf_mval(_CLIENTAPP)=%str(SAS Studio) %then %do;
    %let a=%mf_mval(_CLIENTVERSION);
    %let b=%scan(&a,1,.);
    %if %eval(&b >2) %then %do;
      &b
    %end;
    %else 0;
  %end;
  %else 0;
%end;
%mend;