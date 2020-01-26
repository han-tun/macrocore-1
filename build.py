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
f = open('compileall.sas', "w")             # r / r+ / rb / rb+ / w / wb
f.write(header)
folders=['base','meta','xcmd','viya','lua']
for folder in folders:
    filenames = [fn for fn in Path('./' + folder).iterdir() if fn.match("*.sas")]
    with open('compile' + folder + '.sas', 'w') as outfile:
        for fname in filenames:
            with open(fname) as infile:
                outfile.write(infile.read())
    with open('compile' + folder + '.sas','r') as c:
        f.write(c.read())
filenames=os.listdir('./' + folder)
with open('compile' + folder + '.sas', 'w') as outfile:
    for fname in filenames:
        with open('./' + folder + '/' + fname) as infile:
            outfile.write(infile.read())
with open('compile' + folder + '.sas','r') as c:
    f.write(c.read())
f.close()
