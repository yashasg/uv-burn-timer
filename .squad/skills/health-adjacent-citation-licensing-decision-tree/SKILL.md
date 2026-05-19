# Skill — Health-Adjacent Citation Licensing Decision Tree

> A reusable protocol for tiering sources ✅ / ⚠️ / 🚫 by **license × use-type** for any health-adjacent paid commercial app. Extracted from `.squad/decisions/inbox/plunder-citation-framework.md` (UV Burn Timer, 2026-05-19).

## When to use this skill

You are working on a paid commercial app (App Store, Play Store, or any commercial channel) that touches a health-adjacent domain (dermatology, sleep, nutrition, exercise physiology, mental wellness, etc.) and needs to cite scientific or clinical sources. You need to decide, for each candidate source:

1. Can we cite it?
2. Can we reproduce its content verbatim (table, figure, prose) in the app UI?
3. Can we reproduce it in the App Store description?
4. What's the required attribution string?
5. Is there a safer alternative?

This skill is **not** a substitute for attorney review. It's a triage protocol that lets a non-attorney compliance reviewer issue defensible ✅/⚠️/🚫 verdicts grounded in named licenses and named rules, while flagging genuinely ambiguous cases for escalation.

## The two-axis framing

The verdict for any source is a function of **two independent axes**:

- **Axis 1 — Source license / copyright posture:** What does the source's license say about commercial reuse?
- **Axis 2 — Our use type:** Are we (a) citing, (b) paraphrasing, or (c) reproducing verbatim?

Never collapse these axes. "Can I use this source?" is the wrong question. "Can I use this source THIS WAY?" is the right one. Same source can be ✅ for citation and 🚫 for verbatim reproduction.

## Step 1 — Classify the source by license posture

For each candidate source, identify which bucket it falls into. **Bucket name is the leverage you'll cite when the team pushes back.**

| Bucket | Examples | Default posture |
|---|---|---|
| **B1. U.S. federal public domain** (17 U.S.C. § 105) | NOAA, EPA, FDA, NIH/NLM/NCBI/MedlinePlus, NWS, CDC, NIST, USPHS | ✅ All uses, with courtesy attribution |
| **B2. CC BY (4.0 or earlier)** | Many PLOS papers, many newer open-access works | ✅ All uses, with required CC BY attribution + license tag |
| **B3. CC BY-NC** (4.0 IGO or earlier) | WHO publications, some Codon Publications, many NC-licensed academic books | ✅ Citation; ⚠️ paraphrase OK; 🚫 verbatim reproduction in commercial app |
| **B4. CC BY-NC-SA** (IGO variant common) | WHO INTERSUN, many UN-body publications | Same as B3 + ShareAlike obligation if you make derivatives (which makes derivatives infeasible for commercial closed-source apps) |
| **B5. CC BY-NC-ND** | StatPearls, DermNet NZ, some textbook chapters | Same as B3 PLUS no derivatives — also blocks paraphrase if the paraphrase is a derivative work |
| **B6. CC BY-SA** | Wikipedia, some MediaWiki-hosted content | ✅ Citation; 🚫 verbatim reproduction (ShareAlike contagion) |
| **B7. All-rights-reserved with no open license** | Peer-reviewed journal articles, AAD pages, Mayo/Cleveland Clinic/WebMD, copyrighted books | ✅ Citation by author/year/DOI (universal academic norm, fair use); 🚫 verbatim reproduction without publisher permission |
| **B8. Standards bodies — paid standards** | CIE, ISO, IEC, IEEE, ANSI | ✅ Cite by document number (e.g., "CIE S 007/E-1998"); 🚫 reproduce table values or figures |
| **B9. Trademark / contract attribution** (not copyright) | Apple WeatherKit, Mapbox attribution, Google Maps attribution | Comply with the contract's specific attribution requirements; this is contract law, not copyright |

**Heuristics for finding the bucket:**

- Read the colophon, front matter, or footer of the source itself.
- If the source is hosted on a third-party platform (NCBI Bookshelf, ResearchGate, Academia.edu), the platform license is NOT the source license — find the original publisher's terms.
- If a license has a discrepancy (prose says X but link says Y), the controlling reading is usually the **explanatory text** that describes WHAT users are permitted to do (the operative clause), not the headline tag.
- Be especially careful with WHO and UN-body publications (B4 default), commercial textbook chapters (often B3 or B7), and Bookshelf-hosted publications (each book has its own license).

## Step 2 — Classify our use type

For each use, identify what we're actually doing with the source:

| Use type | Definition | Examples |
|---|---|---|
| **U1. Citation** | Referring to the source by author/title/year/identifier, possibly with a URL link, in About / methodology / references | "Fitzpatrick TB (1988). Arch Dermatol 124(6):869–871." |
| **U2. Paraphrase** | Re-expressing the source's content in our own words while preserving the underlying scientific facts | Rewriting a definition or list in our own language |
| **U3. Verbatim reproduction** | Copying source text, tables, or figures into our app UI or marketing | The Codon Bookshelf Table 1 wording reproduced as picker labels |
| **U4. Computational use of facts** | Using a numerical relationship (e.g., 0.025 W/m² per UVI) in our model code | The MED-extension math |

**Key copyright doctrines that drive the matrix:**

- **Facts and ideas are not copyrightable** (Feist v. Rural Telephone, 499 U.S. 340). The Fitzpatrick scale as a scientific classification, MED values as biological facts, the UVI conversion as a defined unit — all unprotectable. Our **expression** of these facts is our copyrighted work; the source's expression is theirs.
- **Citation falls outside copyright license scope.** Citing a work — referring to its existence by name — is not exercising a Licensed Right under any CC license. Even an NC-licensed work can be cited freely in a commercial app.
- **Paraphrase is murkier.** A paraphrase that preserves the *expressive arrangement* of a source can be a derivative work; a paraphrase that just restates the underlying fact in independent prose is usually safe.
- **Short factual phrases may not meet the originality threshold.** Single sentences of fact-like prose ("White skin. Always burns, never tans.") may fall below the originality bar required for copyright protection — but this is a defense, not a shield, and a paid commercial app should not rely on it without attorney sign-off.

## Step 3 — The verdict matrix

Use this matrix to issue the ✅ / ⚠️ / 🚫 verdict.

| | **U1. Citation** | **U2. Paraphrase** | **U3. Verbatim reproduction** | **U4. Computational use of facts** |
|---|---|---|---|---|
| **B1. U.S. federal public domain** | ✅ | ✅ | ✅ | ✅ |
| **B2. CC BY** | ✅ with attribution | ✅ with attribution | ✅ with attribution + license tag | ✅ |
| **B3. CC BY-NC** | ✅ | ⚠️ (defensible if facts are restated independently) | 🚫 in commercial app | ✅ (facts) |
| **B4. CC BY-NC-SA** | ✅ | ⚠️ + ShareAlike infeasible for closed source | 🚫 in commercial app | ✅ (facts) |
| **B5. CC BY-NC-ND** | ✅ | 🚫 (ND blocks derivatives) | 🚫 in commercial app | ✅ (facts) |
| **B6. CC BY-SA** | ✅ | ⚠️ + ShareAlike contagion | 🚫 (ShareAlike forces our app to be CC BY-SA) | ✅ (facts) |
| **B7. All-rights-reserved** | ✅ (academic citation is fair use) | ⚠️ (defensible if facts restated independently, but obtain permission if uncertain) | 🚫 without publisher permission | ✅ (facts) |
| **B8. Paid standards (CIE, ISO)** | ✅ by document number | 🚫 (tables and figures are the expression) | 🚫 in commercial app | ✅ (compute against the standard) |
| **B9. Trademark/contract (Apple/Mapbox/etc.)** | N/A — follow contract spec | N/A | Use the supplied asset per spec; never modify | N/A |

**How to read the matrix:** intersect the source bucket row with the use-type column. If the cell is ⚠️, propose a safer alternative (e.g., paraphrase instead of reproduce; cite an NOAA equivalent instead of a WHO source; use the originating peer-reviewed paper instead of the third-party-hosted derivative).

## Step 4 — Generate the attribution string

For each ✅ source you adopt, build the canonical attribution string. Every health-adjacent citation should include:

1. **Author / editor** (full names where standard; et al. acceptable for >3 authors after position 3)
2. **Title** of the work (book chapter title for chapters; paper title for papers)
3. **Publisher** for books / standards (not needed for journals)
4. **Journal name + volume/issue/pages** for papers
5. **Year**
6. **Stable identifier** — DOI > IRIS handle > NBK ID > PubMed ID > URL with access date
7. **License tag** for CC-licensed sources (e.g., "Licence: CC BY-NC-SA 3.0 IGO")
8. **Access date** for non-stable URLs only

Maintain a "compact form" for App Store descriptions ("Fitzpatrick TB (1988)") alongside the "full form" for in-app About panels.

## Step 5 — Required disclosure surfaces

For every ✅ source you adopt, decide which surface(s) it must appear on:

- **In-app About panel** — full-form citation for ALL sources. This is the canonical surface.
- **App Store description** — compact form, only the 3–5 most important. Don't pad.
- **Contract-required attribution surfaces** (e.g., WeatherKit lockup on home screen) — per the contract.
- **First-launch disclaimer** — NEVER. Disclaimer is for safety messaging, not citations.

## Common traps

1. **Treating Bookshelf-hosted works as federal public domain.** They're not. The hosted book's own license governs.
2. **Treating "free to download" as "free to redistribute commercially."** ICNIRP, CIE, AAD all distribute free PDFs but retain copyright.
3. **Trusting a colophon's headline over its operative explanatory text.** When prose and link disagree, the operative description controls.
4. **Reproducing short factual phrases verbatim "because they're short."** Short phrases may fall below the originality threshold, but a paid commercial app should not bet on this without attorney review. Paraphrase is cheap insurance.
5. **Using WHO content in a paid app because "citation is OK."** Citation IS OK; reproduction is not. Distinguish carefully.
6. **Citing Wikipedia as a scientific anchor.** Wikipedia is great research scaffolding but ShareAlike contagion plus a credibility hit make it unsuitable as a primary citation.
7. **Listing brand-named medications.** Trademark-adjacent, tone-advisory. Always use therapeutic classes.
8. **Putting the attribution in a sub-screen when the contract requires primary-surface placement.** Read the contract; lockups often need to be on the data-display screen, not buried in About.
9. **Forgetting that App Store category choice changes the rule set.** A Utilities-category app and a Medical-category app are reviewed differently. Don't write copy that pushes you into a stricter category by accident.

## When to escalate to attorney

Any of the following:

- Source license has an internal contradiction you cannot resolve from public materials.
- You want to reproduce a B3/B4/B5/B7 source verbatim in the app or App Store description.
- You're using a regulated word (e.g., "personalized," "diagnose," "treat," "cure") and aren't sure it survives App Store review.
- You're publishing trademark-adjacent content (brand-named medications, brand-named devices, brand-named tests).
- You're drafting Privacy Policy / ToS clauses that touch health data.
- You're getting close to a category recategorization risk (Utilities → Health & Fitness / Medical).

Flag these in a single "open attorney escalations" section of your framework deliverable. Do not block design/build work waiting for the attorney — design assumes the conservative posture, and the attorney either ratifies or refines.

## Output format

When this skill is used, produce a deliverable with at minimum:

1. **Source-by-source verdict table** (✅/⚠️/🚫 with cited rule).
2. **Attribution-string spec** (full form + compact form per source).
3. **"Things to NOT cite"** list (inverse legal pack — common gotchas in the domain).
4. **Disclaimer wording** (if the app has a disclaimer surface).
5. **App Store description claim review** (line-by-line ✅/⚠️/🚫 with rewrites).
6. **Open attorney escalations** (named items, none blocking design).

## See also

- `.squad/decisions/inbox/plunder-citation-framework.md` — the worked example for UV Burn Timer.
- The CC license deeds (https://creativecommons.org/licenses/) — read the actual deeds, not summaries.
- App Store Review Guidelines (Apple) — §1.4 Safety, §1.4.3 Drugs/Medical Topics, §5.1 Privacy, §5.2 Intellectual Property.
- 17 U.S.C. § 105 (U.S. federal work copyright posture), Feist v. Rural Telephone (originality threshold for fact compilations).
