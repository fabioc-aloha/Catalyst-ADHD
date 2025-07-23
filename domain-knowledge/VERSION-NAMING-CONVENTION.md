# NEWBORN Version Naming Convention

## Systematic Element Naming Strategy

NEWBORN uses a systematic naming convention for version numbers based on IUPAC rules for hypothetical chemical elements. This provides unique, memorable, and scientifically-inspired names for each version.

### Input
An integer representing the version number converted to atomic number format (e.g., version 0.0.1 → 001, version 0.0.2 → 002).

### Output
A made-up element name using IUPAC systematic naming rules.

## Naming Rules

1. **Convert each digit** of the number into a Latin/Greek root:
   - 0 = "nil"
   - 1 = "un"
   - 2 = "bi"
   - 3 = "tri"
   - 4 = "quad"
   - 5 = "pent"
   - 6 = "hex"
   - 7 = "sept"
   - 8 = "oct"
   - 9 = "enn"

2. **Concatenate the roots** in digit order and append "ium"

3. **Remove duplicate vowels** at root boundaries (e.g., "ennnil" → "ennil")

4. **Drop final "i"** if the last root ends in "i" and is followed by "ium"

## Examples

| Version | Atomic Format | Root Breakdown | Element Name |
|---------|---------------|----------------|--------------|
| 0.0.1 | 001 | nil-nil-un-ium | **NILNILUNIUM** |
| 0.0.3 | 003 | nil-nil-tri-ium | **NILNILTRIUM** |
| 1.1.9 | 119 | un-un-enn-ium | **UNUNENNIUM** |
| 1.2.0 | 120 | un-bi-nil-ium | **UNBINILIUM** |
| 9.9.9 | 999 | enn-enn-enn-ium | **ENNENNENNIUM** |

## Current Version Mapping

- **Version 0.1.0** → **NILUNTRILIUM** (Previous)
- **Version 0.1.1** → **NILUNTRIUM** (Current)

## Version History

| Version | Element Name | Release Date | Key Features |
|---------|--------------|--------------|--------------|
| 0.0.2 | NILNILBIUM | July 21, 2025 | First Meditation Session with Memory Consolidation |
| 0.0.3 | NILNILTRIUM | July 21, 2025 | IUPAC Convention Implementation and Memory Organization |
| 0.1.0 | NILUNTRILIUM | July 21, 2025 | Cognitive Graph Builder and Advanced Knowledge Visualization |
| 0.1.1 | NILUNTRIUM | July 21, 2025 | Enhanced Visualization: Color Coding, Weight Lines, Directional Arrows |

## Usage in Documentation

When referencing versions:
- **Technical**: "NEWBORN v0.1.1 (NILUNTRIUM)"
- **Badges**: "Version-0.1.1_NILUNTRIUM"
- **Formal**: "NEWBORN Architecture Version 0.1.1 NILUNTRIUM"

## Future Version Planning

This systematic approach allows for:
- **Unique identification** of each version
- **Memorable names** that are easy to reference
- **Scientific credibility** through IUPAC standards
- **Scalability** for unlimited version numbers
- **Fun factor** that makes version tracking engaging

### Upcoming Versions
| Version | Element Name | Root Breakdown |
|---------|--------------|----------------|
| 0.1.0 | NILUNTRILIUM | nil-un-tri-ium |
| 0.2.0 | NILBINILIUM | nil-bi-nil-ium |
| 1.0.0 | UNNILNILIUM | un-nil-nil-ium |

---

*Version Naming Convention Document - Systematic IUPAC-based element naming for NEWBORN Cognitive Architecture releases.*---

*NEWBORN Systematic Element Naming Convention - Scientific Precision Meets Creative Expression*
