```
 ______    _______  _______  _______  __   __  ______    __   __
|    _ |  |   _   ||       ||       ||  | |  ||    _ |  |  | |  |
|   | ||  |  |_|  ||       ||    ___||  | |  ||   | ||  |  |_|  |
|   |_||_ |       ||       ||   |___ |  |_|  ||   |_||_ |       |
|    __  ||       ||      _||    ___||       ||    __  ||_     _|
|   |  | ||   _   ||     |_ |   |    |       ||   |  | |  |   |
|___|  |_||__| |__||_______||___|    |_______||___|  |_|  |___|
```

```
>>> RACF ENUMERATION SUBSYSTEM v1.0 <<<
>>> UNAUTHORIZED ACCESS WILL BE PROSECUTED <<<
>>> ... JUST KIDDING. YOU JUST SEE WHAT YOU HAVE<<<
```

---

## [ WHAT IS THIS ]

**RACFURY** is a REXX script that runs on IBM z/OS and tells you **exactly what you're allowed to touch** on the mainframe — datasets, commands, facilities, Unix privileges, the works.

It speaks to RACF (Resource Access Control Facility), IBM's iron-fisted security overlord that has been guarding mainframes since 1976. You can't bluff RACF. But you *can* ask it nicely what it'll let you do.

That's what RACFURY does.

---

## [ HOW IT WORKS ]

```
┌─────────────────────────────────────────────────┐
│  YOUR TSO SESSION                               │
│                                                 │
│  RACFURY.REXX                                   │
│       │                                         │
│       ├─► SEARCH ALL NOMASK                     │
│       │       └─► every dataset profile you     │
│       │           have access to                │
│       │                                         │
│       ├─► LISTDSD DATASET(x)                    │
│       │       └─► YOUR ACCESS for each one      │
│       │                                         │
│       ├─► SEARCH CLASS(x) MASK(*)               │
│       │       └─► all general resource profiles │
│       │                                         │
│       └─► RLIST class profile                   │
│               └─► YOUR ACCESS for each one      │
└─────────────────────────────────────────────────┘
```

Output is colon-separated. Feed it to a spreadsheet, a SIEM, a shell pipeline, whatever:

```
DATASET:SYS1.PARMLIB.**:READ
FACILITY:BPX.SUPERUSER:READ
UNIXPRIV:SUPERUSER:UPDATE
OPERCMDS:MVS.VARY.TCPIP.*:CONTROL
```

---

## [ CLASSES ENUMERATED ]

| Class       | What lives there                        |
|-------------|------------------------------------------|
| `FACILITY`  | System facilities, BPX stuff, you name it|
| `UNIXPRIV`  | z/OS Unix privilege overrides            |
| `PROGRAM`   | Controlled program access                |
| `JESSPOOL`  | JES spool resource profiles              |
| `OPERCMDS`  | Operator command authority               |
| `TSOAUTH`   | TSO command authorizations               |
| `SDSF`      | SDSF panel and filter access             |
| `SURROGAT`  | Surrogate submission profiles            |
| `XFACILIT`  | As `FACILITY` just with the longer names |
| `JESJOBS`   | What can we submit/cancel                |
| `TERMINAL`  | What (TSO) terminals can we access       |
| `APPL`      | What applications? (TSO/CICS/TWS/etc.)   |
| `VTAMAPPL`  | Can we open some ACBs?                   |
| `CSFKEYS`   | ICSF cryptographic keys and services     |
| `DIGTCERT`  | Digital Certificates                     |
| `DIGTRING`  | Key rings                                |


Want more? Edit the `classes` line in the source. It's literally one line. Go nuts.

---

## [ RUNNING IT ]

**From TSO/ISPF:**
Upload the `RACFURY.rexx` to your REXX LIB or use the `RACFURY.XMIT` file.

```
EXEC 'YOUR.REXX.LIB(RACFURY)'
```

**From z/OS Unix (OMVS/SSH/USS):**
Upload  `RACFURY.rexx` into an USS folder.

```sh
chmod +x RACFURY/rexx
./RACFURY.rexx
```

RACFURY auto-detects whether it's running under TSO, ISPF, or OMVS and adjusts accordingly. No flags. No config files. No nonsense.


---

## [ WHO SHOULD RUN THIS ]

- **Security reviewers** performing RACF access audits
- **Penetration testers** on authorized mainframe engagements
- **Sysadmins** who've inherited a z/OS environment and want to know what they can do
- **Developers** who keep getting `ICH408I` errors and just want to see what RACF will actually let them touch
- **Curious people** who found a TSO prompt and wondered what the deal was

RACFURY only shows **YOUR** access. It runs as you. It cannot escalate. It cannot enumerate other users' permissions. It asks RACF politely and RACF tells it what you're allowed to see.

---

## [ REQUIREMENTS ]

- z/OS (any reasonably modern release)
- REXX (ships with z/OS — already there)
- TSO/E (also ships with z/OS — also already there)
- A valid TSO userid with RACF active
- READ access to the resource classes you want to enumerate (you can only see what you can see)

No third-party software. No downloads. No npm install. Just REXX on an IBM mainframe the way God and IBM intended.

---

## [ KNOWN QUIRKS ]

- Profiles you have **NONE** access to are silently skipped — the output only shows what you can actually use
- Very large RACF databases may take a while to enumerate — RACFURY does a lot of individual LISTDSD and RLIST calls

---

## [ AUTHOR ]

**Wizard of z/OS** — 2026

*"The mainframe was here before you. It will be here after you. Be polite to it."*

---

```
[ END OF LINE ]
```
