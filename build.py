import os
from pathlib import Path

# Prepare Lua Macros
files = [f for f in Path('lua').iterdir() if f.match("*.lua")]
for file in files:
    basename=os.path.basename(file)
    name='ml_' + os.path.splitext(basename)[0]
    ml = open('lua/' + name + '.sas', "w")
    ml.write("/**\n")
    ml.write("  @file " + name + '.sas\n')
    ml.write("  @brief Creates the " + basename + " file\n")
    ml.write("  @details Writes " + basename + " to the work directory\n")
    ml.write("  Usage:\n\n")
    ml.write("      %" + name + "()\n\n")
    ml.write("**/\n\n")
    ml.write("%macro " + name + "();\n")
    ml.write("data _null_;\n")
    ml.write("  file \"%sysfunc(pathname(work))/" + basename + "\";\n")
    with open(file) as infile:
        for line in infile:
          ml.write("  put '" + line.rstrip().replace("'","''") + " ';\n")
    ml.write("run;\n")
    ml.write("%mend;\n")
ml.close()

# prepare web files
files=['viya/mv_createwebservice.sas','meta/mm_createwebservice.sas']
for file in files:
    if file=='viya/mv_createwebservice.sas':
        webout=open('viya/mv_webout.sas',"r")
    else:
        webout=open('meta/mm_webout.sas','r')
    outfile=open(file + 'TEMP','w')
    infile=open(file,'r')
    delrow=0
    for line in infile:
        if line=='/* WEBOUT BEGIN */\n':
            delrow=1
            outfile.write('/* WEBOUT BEGIN */\n')
            stripcomment=1
            for w in webout:
                if w=='**/\n': stripcomment=0
                elif stripcomment==0:
                    outfile.write("  put '" + w.rstrip().replace("'","''") + " ';\n")
        elif delrow==1 and line=='/* WEBOUT END */\n':
                delrow=0
                outfile.write('/* WEBOUT END */\n')
        elif delrow==0:
            outfile.write(line.rstrip() + "\n")
    webout.close()
    outfile.close()
    infile.close()
    os.remove(file)
    os.rename(file + 'TEMP',file)


# Concatenate all macros into a single file
header="""
/**
  @file
  @brief Auto-generated file
  @details
    This file contains all the macros in a single file - which means it can be
    'included' in SAS with just 2 lines of code:

      filename mc url
        "https://raw.githubusercontent.com/macropeople/macrocore/master/compileall.sas";
      %inc mc;

    The `build.py` file in the https://github.com/macropeople/macrocore repo
    is used to create this file.

  @author Allan Bowe
**/
"""
f = open('mc_all.sas', "w")             # r / r+ / rb / rb+ / w / wb
f.write(header)
folders=['base','meta','metax','viya','lua']
for folder in folders:
    filenames = [fn for fn in Path('./' + folder).iterdir() if fn.match("*.sas")]
    filenames.sort()
    with open('mc_' + folder + '.sas', 'w') as outfile:
        for fname in filenames:
            with open(fname) as infile:
                outfile.write(infile.read())
    with open('mc_' + folder + '.sas','r') as c:
        f.write(c.read())
f.close()
