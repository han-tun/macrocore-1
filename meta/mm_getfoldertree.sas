/**
  @file mm_getfoldertree.sas
  @brief Returns all folders / subfolder content for a particular root
  @details Shows all members and SubTrees recursively for a particular root.
    Usage:

    %mm_getfoldertree(root=/My/Meta/Path, outds=iwantthisdataset)

  @param root= the parent folder under which to return all contents
  @param outds= the dataset to create that contains the list of directories
  @param mDebug= set to 1 to show debug messages in the log

  <h4> Dependencies </h4>

  @version 9.4
  @author Allan Bowe

**/
%macro mm_getfoldertree(
     root=
    ,outds=work.mm_getfoldertree
    ,mDebug=0
    ,depth=50 /* how many nested folders to query */
    ,level=1 /* system var - to track current level depth */
    ,append=NO  /* system var - when YES means appending within nested loop */
)/*/STORE SOURCE*/;

%if &level>&depth %then %return;

%local mD;
%if &mDebug=1 %then %let mD=;
%else %let mD=%str(*);
%&mD.put Executing &sysmacroname;
%&mD.put _local_;

%if &append=NO %then %do;
  /* ensure table doesn't exist already */
  data &outds; run;
  proc sql; drop table &outds;
%end;

/* get folder contents */
data &outds.TMP
  (keep=metauri assoctype name publictype MetadataUpdated MetadataCreated path);
  length metauri pathuri name assoctype $256 path $1024
    publictype MetadataUpdated MetadataCreated $32;
  call missing(of _all_);
  path="&root";
  rc=metadata_pathobj("",path,"Folder",publictype,pathuri);
  if publictype ne 'Tree' then do;
    putlog 'WARNING: Tree ' path 'does not exist!' publictype=;
    stop;
  end;
  __n1=1;
  do while(metadata_getnasl(pathuri,__n1,assoctype)>0);
    __n1+1;
    /* Walk through all possible associations of this object. */
    __n2=1;
    do while(metadata_getnasn(pathuri,trim(assoctype),__n2,metauri)>0);
      __n2+1;
      call missing(name,publictype,MetadataUpdated,MetadataCreated);
      __rc1=metadata_getattr(metauri,"Name", name);
      __rc2=metadata_getattr(metauri,"MetadataUpdated", MetadataUpdated);
      __rc3=metadata_getattr(metauri,"MetadataCreated", MetadataCreated);
      __rc4=metadata_getattr(metauri,"PublicType", PublicType);
      if assoctype in ('Members','SubTrees') then output;
    end;
    n1+1;
  end;
  drop __:;
run;

proc append base=&outds data=&outds.TMP;
run;

data _null_;
  set &outds.TMP;
  if assoctype='SubTrees' then call execute('%mm_getfoldertree(root='
    !!cats(path,"/",name)!!",outds=&outds,mDebug=&mdebug,depth=&depth"
    !!",level=%eval(&level+1),append=YES)");
run;

%mend;
