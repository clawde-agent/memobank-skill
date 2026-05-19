# Memory Write Templates

Copy the relevant template below when writing a memory with `memo write`.
Fill in every `<placeholder>` — do not leave any angle-bracket placeholders in the final memory.

Load this file when: about to run `memo write` and need the correct frontmatter structure.

---

## lesson — for bug fixes and unexpected behavior

````markdown
---
name: <kebab-case-slug>
type: lesson
description: "<one sentence: what was learned>"
tags: [<tag1>, <tag2>]
status: experimental
confidence: medium
---

## Problem
<what went wrong or what was unexpected>

## Root Cause
<why it happened>

## Solution
<what fixed it>

## Applies When
<conditions under which this lesson is relevant>
````

---

## decision — for architecture and technology choices

````markdown
---
name: <kebab-case-slug>
type: decision
description: "<one sentence: what was decided>"
tags: [<tag1>, <tag2>]
status: experimental
confidence: high
---

## Context
<situation and constraints that led to this decision>

## Decision
<what was chosen>

## Alternatives Considered
<what was rejected and why>

## Consequences
<tradeoffs accepted>
````

---

## workflow — for repeatable processes

````markdown
---
name: <kebab-case-slug>
type: workflow
description: "<one sentence: what process this captures>"
tags: [<tag1>, <tag2>]
status: experimental
---

## Trigger
<when to use this workflow>

## Steps
1. <step>
2. <step>

## Notes
<caveats, environment requirements, or known variations>
````

---

## architecture — for system structure documentation

````markdown
---
name: <kebab-case-slug>
type: architecture
description: "<one sentence: what structure this documents>"
tags: [<tag1>, <tag2>]
status: experimental
---

## Overview
<what this architectural pattern or decision covers>

## Structure
<how components are organized>

## Rationale
<why this structure was chosen over alternatives>
````
