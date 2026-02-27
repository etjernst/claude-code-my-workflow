# Session log: feedback on Bao Vu's research proposal

**Date:** 2026-02-27
**Status:** IN PROGRESS

---

## Goal

Use the new `/research-feedback` skill to review a Masters student's proposal on public-private wage differentials in Vietnam (VHLSS 2022). Produce constructive feedback as an email draft.

## Student details

- Khac Gia Bao Vu (49033700), MQBS8980: Business Research Practice, Macquarie University
- Masters-level, labor economics subfield
- Proposal: "The Impact of COVID-19 on the Public Sector Wage Premium in Vietnam: New Evidence from the Vietnam Household Living Standard Survey"
- File: `C:\Users\maand\OneDrive\Desktop\git\workwork\projects\MQ\advising\BaoVu\`

## Key feedback issues identified

### 1. Sector classification is wrong (most urgent)

Student claims to use VSIC industry codes ("occupation code of your full-time job") to classify public vs private. But VSIC classifies by nature of economic activity, not ownership---its official documentation says so explicitly. The codes listed (C_public = {0, 01, 02, 03, 11, 12, ...}) don't match standard VSIC 2-digit divisions.

Phan & O'Brien (2025), whom the student cites as a methodological template, actually use a completely different variable: the VHLSS economic type question ("For which organisations/individuals has [name] worked?") with six categories: (1) farming household, (2) independent business, (3) collective, (4) private enterprise, (5) state-run, (6) foreign-invested. They code state-run = public, exclude collectives, everything else = private.

Student needs to switch to this economic type variable.

### 2. Single cross-section can't answer the research question

Title promises "impact of COVID-19" but only has 2022 data. With one cross-section, can estimate the premium's level but not its change. Needs at least the 2018 VHLSS wave for a before-after comparison. DiD-style design with pooled repeated cross-sections is the realistic path.

Phan & O'Brien (2025) confirm that the VHLSS 2020 sample is completely independent of 2018 (no panel tracking). McCaig documents individual panel linkages only through 2010--12. Individual fixed effects are off the table.

### 3. Selection bias unaddressed

OLS coefficient (4.3%) interpreted as "the premium" without grappling with worker self-selection into sectors. Needs at minimum careful language ("associated with" not "earn more"), and ideally Heckman correction or propensity score matching (Vu & Yamada 2020 provide a template).

Imbert (2013) raises additional concern: VHLSS draws from official population registers, excluding unregistered urban migrants who are disproportionately private sector workers. This biases the private-sector wage distribution upward.

### 4. Bad controls

Formal contract status (85% public vs 47% private) and social insurance are outcomes of sector choice, not confounders. Controlling for them absorbs the premium being measured. Baseline should use only pre-determined variables; test contract/insurance inclusion as sensitivity.

### 5. Four problematic references

- Lausev: bibliography says 2014, in-text says 2013 (Zotero sync issue)
- Miaari (2018): unfindable
- Tansel (2005): cited for sub-Saharan Africa but paper is about Turkey
- Depalo (2018): unfindable as solo-authored; likely Depalo et al. (2015)

### 6. COVID angle may be weak

With only repeated cross-sections, attributing premium changes to COVID (vs everything else that changed) is very hard. Exploring alternative framings:
- Oaxaca-Blinder decomposition across waves
- Quantile decomposition (premium varies across wage distribution)
- Formalization story (formal vs informal within private sector)
- Returns to education across sectors
- SOE vs government administration distinction
- Gender and the sectoral wage gap

## Output

Feedback email saved to `BaoVu/feedback-proposal.md` with:
- Structured feedback (economic reasoning, data needs, sector classification, selection, bad controls, descriptive work, scope, references, next steps)
- Bibliography separated into proposal references (with 4 flagged) and feedback-only references
- Citation verification notes

## Open questions

- Which alternative framing to recommend (pending user input)
- Whether to add alternative approaches to the email


---
**Context compaction (auto) at 12:11**
Check git log and quality_reports/plans/ for current state.


---
**Context compaction (auto) at 12:12**
Check git log and quality_reports/plans/ for current state.
