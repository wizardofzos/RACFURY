/* REXX ----------------------------------------------------------------
   GETACCESS - Enumerate all RACF access for the current TSO user
               and output results as colon seperated lines.

   Technique:
     SEARCH ALL NOMASK       -- all dataset profiles user can access
     LISTDSD DATASET(x)      -- YOUR ACCESS for a dataset profile
     SEARCH CLASS(x) MASK(*) -- all profiles in a general resource class
     RLIST class profile     -- YOUR ACCESS for a general resource profile

   To add or remove classes, edit the CLASSES line below.

   Output format:
     CLASS:PROFILE:ACCESS
     e.g. DATASET:MY.DATA.**:READ

  Wizard of z/OS 
  2026
   --------------------------------------------------------------------- */

/* ---- Edit this list to add or remove general resource classes ------- */
classes = 'FACILITY UNIXPRIV PROGRAM JESSPOOL OPERCMDS'
classes = classes 'TSOAUTH SDSF SURROGAT XFACILIT SDSF JESJOBS'
classes = classes 'TERMINAL APPL VTAMAPPL CSFKEYS DIGTCERT DIGTRING'



/* ---- Detect execution environment ------------------------------------ */
addr = ADDRESS()
if addr = 'OMVS' | addr = 'SH' then
  runenv = 'OMVS'
else do
  runenv = 'TSO'
  if sysvar('SYSISPF') = 'ACTIVE' then runenv = 'ISPF'
end

/* ---- We need some ebcdic art obviously ------------------------------ */
say " ______    _______  _______  _______  __   __  ______    __   __ "
say "|    _ |  |   _   ||       ||       ||  | |  ||    _ |  |  | |  |"
say "|   | ||  |  |_|  ||       ||    ___||  | |  ||   | ||  |  |_|  |"
say "|   |_||_ |       ||       ||   |___ |  |_|  ||   |_||_ |       |"
say "|    __  ||       ||      _||    ___||       ||    __  ||_     _|"
say "|   |  | ||   _   ||     |_ |   |    |       ||   |  | |  |   |  "
say "|___|  |_||__| |__||_______||___|    |_______||___|  |_|  |___|  "
say ""
say "Wizard of z/OS - 2026                       [RUNNING IN "runenv"]"
say ""
say "Retrieving access for" USERID()
say ""

/* ---- 1. DATASETS --------------------------------------------------- */
call runtso runenv, 'SEARCH ALL NOMASK'

do i = 1 to out.0
  prof = strip(word(out.i, 1))
  if prof = ''          then iterate
  /* Skip any error messages */
  if abbrev(prof,'ICH') then iterate
  if abbrev(prof,'IRR') then iterate

  acc = getDSAccess(prof, runenv)
  if acc = '' | acc = 'NONE' then iterate

  say 'DATASET:'prof':'acc
end

/* ---- 2. GENERAL RESOURCE CLASSES ----------------------------------- */
do c = 1 to words(classes)
  cls = word(classes, c)

  call runtso runenv, 'SEARCH CLASS('cls') MASK(*)'

  do p = 1 to out.0
    prof = strip(out.p)
    if prof = ''            then iterate
    /* Skip these again */
    if abbrev(prof,'ICH')   then iterate
    if abbrev(prof,'IRR')   then iterate
    if words(prof) > 1      then iterate

    acc = getRLAccess(cls, prof, runenv)
    if acc = '' | acc = 'NONE' | acc = 'N/A' then iterate

    say cls':'prof':'acc
  end
end

exit

/* --------------------------------------------------------------------- *
 * runtso(runenv, cmd)                                                   *
 *   Run a TSO command and put the output lines into out. stem.          *
 *   TSO/ISPF: outtrap + ADDRESS TSO                                     *
 *   OMVS:     BPXWUNIX('/bin/tsocmd/...', ...)                          *
 * -------------------------------------------------------------------- */
runtso: procedure expose out.
  parse arg runenv, cmd
  drop out.
  if runenv = 'OMVS' then do
    out.0 = 0        /* BPXWUNIX reads .0 before writing; must be */
    err.0 = 0        /* a number, not the default 'OUT.0' string  */
    c = '/bin/tsocmd "'cmd'"'
    rc = BPXWUNIX(c,, out., err.)
  end
  else do
    x = outtrap('out.')
    address tso (cmd)
    x = outtrap('off')
  end
  return

/* -------------------------------------------------------------------- *
 * getDSAccess(dsname, runenv)                                          *
 *   Run LISTDSD and extract YOUR ACCESS.                               *
 *   LISTDSD shows YOUR ACCESS as a standalone section:                 *
 *     YOUR ACCESS                                                      *
 *     -----------                                                      *
 *     READ                                                             *
 *   so the value is 2 lines below the header line (word 1).            *
 * -------------------------------------------------------------------- */
getDSAccess: procedure
  parse arg dsname, runenv
  call runtso runenv, "LISTDSD DATASET('"dsname"')"
  result = ''
  do j = 1 to out.0
    if pos('YOUR ACCESS', out.j) > 0 then do
      dline = j + 2
      if dline <= out.0 then result = word(out.dline, 1)
    end
  end
  return result

/* --------------------------------------------------------------------- *
 * getRLAccess(cls, profile, runenv)                                     *
 *   Run RLIST and extract YOUR ACCESS.                                  *
 *   RLIST shows YOUR ACCESS inline with other fields:                   *
 *     LEVEL  OWNER   UNIVERSAL ACCESS  YOUR ACCESS  WARNING             *
 *     -----  ------  ----------------  -----------  -------             *
 *      00    OWNER        NONE              READ     NO                 *
 *   Use column position of "YOUR ACCESS" header to extract the value.   *
 * -------------------------------------------------------------------- */
getRLAccess: procedure
  parse arg cls, prof, runenv
  call runtso runenv, 'RLIST' cls prof
  result = ''
  do j = 1 to out.0
    if pos('YOUR ACCESS', out.j) > 0 then do
      col   = pos('YOUR ACCESS', out.j)
      dline = j + 2
      if dline <= out.0 then
        result = word(substr(out.dline, col, 14), 1)
    end
  end
  return result

