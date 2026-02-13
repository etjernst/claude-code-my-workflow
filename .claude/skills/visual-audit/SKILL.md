---
name: visual-audit
description: Perform adversarial visual audit of Beamer slides checking for overflow, font consistency, box fatigue, and layout issues.
disable-model-invocation: true
argument-hint: "[TEX filename]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Visual Audit of Slide Deck

Perform a thorough visual layout audit of a Beamer slide deck.

## Steps

1. **Read the slide file** specified in `$ARGUMENTS`

2. **For Beamer (.tex) files:**
   - Compile and check for overfull hbox warnings

3. **Audit every slide for:**

   **OVERFLOW:** Content exceeding slide boundaries
   **FONT CONSISTENCY:** Inconsistent font sizes across similar slide types
   **BOX FATIGUE:** 2+ colored boxes on one slide, wrong box types
   **SPACING:** Vertical spacing issues
   **LAYOUT:** Missing transitions, missing framing sentences, semantic colors

4. **Produce a report** organized by slide with severity and recommendations

5. **Follow the spacing-first principle:**
   1. Reduce vertical spacing with negative margins
   2. Consolidate lists
   3. Move displayed equations inline
   4. Reduce image size
   5. Last resort: font size reduction
