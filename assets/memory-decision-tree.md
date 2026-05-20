# Memory Decision Tree

Use this diagram to decide **whether to write a memory, which tier to use, and when to distill or self-improve**.

Load this file when: deciding whether an event is worth capturing, choosing a tier, or triggering the self-improvement loop.

```mermaid
flowchart TD
    START([Something happened during this session]) --> OBV{Non-obvious?\nNot already\ndocumented?}

    OBV -->|No| SKIP[fa:fa-times Skip — do not write]
    OBV -->|Yes — HIGH FREEDOM\nuse judgment| TYPE{What type\nof learning?}

    TYPE -->|Bug fix /\nunexpected behavior| TL[lesson]
    TYPE -->|Architecture /\ntech choice| TD[decision]
    TYPE -->|Repeatable\nprocess| TW[workflow]
    TYPE -->|System\nstructure| TA[architecture]

    TL & TD & TW & TA --> WHO{Who benefits?\nMEDIUM FREEDOM\npreferred logic}

    WHO -->|Only me /\nmachine-specific| PERS["🔒 Personal tier
    memo write <type> \
      --name='...' \
      --repo ~/.memobank/PROJECT/"]

    WHO -->|Team /\ncodebase-specific| PROJ["📁 Project tier  ← default
    memo write <type> \
      --name='...' \
      --description='...' \
      --tags='...' \
      --content='...'"]

    WHO -->|Cross-repo / org-wide /\nbiz decisions / BA+PO context /\nnon-code project knowledge| WS["🌐 Workspace tier
    memo write <type> ... then
    memo workspace publish FILE
    (remote can be an existing wiki repo)"]

    PROJ --> MAT{Project mature?\n10+ memories?\nRecurring patterns?}
    MAT -->|Not yet| DONE1([Done])
    MAT -->|Thematic clusters\nLOW FREEDOM| SC["memo distill --to scenes"]
    MAT -->|Promote personal\nLOW FREEDOM| DP["memo distill --to personal"]
    MAT -->|Cross-repo value\nLOW FREEDOM| DW["memo distill --to workspace"]

    PERS & WS & SC & DP & DW --> SELF{Self-improve?\nHIGH FREEDOM}

    SELF -->|Lesson recalled\n3+ times| STUDY["memo study LESSON-NAME
    LOW FREEDOM — injects into CLAUDE.md"]
    SELF -->|Memories feel\nstale or noisy| SCAN["memo lifecycle --scan
    LOW FREEDOM — auto-downgrades stale"]
    SELF -->|Not yet| DONE2([Done])
```

## Degree-of-Freedom Key

| Label | Meaning | Examples in this tree |
|-------|---------|----------------------|
| **HIGH FREEDOM** | Use judgment — multiple valid choices | Should I write? Self-improve now? |
| **MEDIUM FREEDOM** | Follow preferred logic, variation OK | Which tier? |
| **LOW FREEDOM** | Exact command, no variation | `memo distill`, `memo study`, `memo lifecycle --scan` |
