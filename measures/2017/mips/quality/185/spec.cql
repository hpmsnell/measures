library MIPS_185_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 185
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 185 Encounter"
valueset "MIPS; History of Adenomatous Polyps"
valueset "MIPS; Performance Met: 0529F"
valueset "MIPS; Denominator Exception: 0529F-1P"
valueset "MIPS; Denominator Exception: 0529F-3P"
valueset "MIPS; Performance Not Met: 0529F-8P"

// VSAC value sets

valueset "VSAC; Colon Cancer": 2.16.840.1.113883.3.526.3.391

// Able value sets

valueset "Able; Chron's Disease"
valueset "Able; Ulcerative Colitis"
valueset "Able; Lower Gastrointestinal Bleeding"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 185 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {52, 53, 73, 74}
    with ["Diagnosis": "MIPS; History of Adenomatous Polyps"] D
      such that D.prevalencePeriod starts during or before start of E.relevantPeriod

define "Competing Condition for Colonoscopy":
  ["Diagnosis": "Able; Chron's Disease"]
  union ["Diagnosis": "VSAC; Colon Cancer"]
  union ["Diagnosis": "Able; Ulcerative Colitis"]
  union ["Diagnosis": "VSAC; Able; Lower Gastrointestinal Bleeding"]

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: 0529F":
  /*
   * config_link_id: 0529F
   */
  exists(["Encounter, Performed": "MIPS; Performance Met: 0529F"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or not exists("MIPS; MIPS 185 Encounter" E1
    with "Denominator Encounter" E2
      such that E1.relevantPeriod starts 3 years or less before start of E.relevantPeriod)

define "Denominator Exception: 0529F-1P":
  /*
   * config_link_id: 0529F-1P
   */
  exists(["Encounter, Performed": "MIPS; Denominator Exception: 0529F-1P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Competing Condition for Colonoscopy" D
    with "Denominator Encounter" E
      such that D.prevalencePeriod starts during or before start of E.relevantPeriod)

define "Denominator Exception: 0529F-3P":
  /*
   * config_link_id: 0529F-3P
   */
  exists(["Encounter, Performed": "MIPS; Denominator Exception: 0529F-3P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: 0529F-8P":
  /*
   * config_link_id: 0529F-8P
   */
  not "Numerator Performance Met: 0529F"
  anf not "Denominator Exception: 0529F-1P"
  anf not "Denominator Exception: 0529F-3P"
