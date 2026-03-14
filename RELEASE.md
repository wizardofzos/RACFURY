# RACFURY Release

## What’s included
- Updated XMIT generation
- Take this file and add to the new release

## Installation
Upload `RACFURY.XMIT` in binary to a preallocated `HQL.YOUR.XMIT` and issue:

````
  TSO RECEIVE INDA('HLQ.YOUR.XMIT')
````

### Preallocating HLQ.YOUR.XMIT

Via TSO command:

````
ALLOC DA('HLQ.YOUR.XMIT')   +
      F(XMITIN)             +
      SPACE(500,100) TRACKS +
      RECFM(F,B) LRECL(80)  +
      BLKSIZE(3120)         +
      DSORG(PS) NEW
````

Or via JCL:

````
//STEP1    EXEC PGM=IEFBR14
//DD1        DD DSN=HLQ.YOUR.XMIT,
//              DISP=(NEW,CATLG,DELETE),
//              UNIT=SYSDA,
//              SPACE=(TRK,(500,100),RLSE),
//              DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120)
````

