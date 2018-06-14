library MIPS_439_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 439
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 439 Encounter"
valueset "MIPS; Performance Met: G9659"
valueset "MIPS; Denominator Exception: G9660"
valueset "MIPS; Performance Not Met: G9661"

// VSAC value sets

valueset "VSAC; Colon Cancer": 2.16.840.1.113883.3.526.3.391

// Able value sets

valueset "Able; Chron's Disease"
valueset "Able; Ulcerative Colitis"
valueset "Able; Lower Gastrointestinal Bleeding"
valueset "Able; Iron Deficiency Anemia"
valueset "Able; Familial Adenomatous Polyposis"
valueset "Able; Lynch Syndrome"
valueset "Able; Inflammatory Bowel Disease"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 439 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 86
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {52, 53, 73, 74}

define "Valid Condition for Colonoscopy":
  ["Diagnosis": "Able; Chron's Disease"]
  union ["Diagnosis": "VSAC; Colon Cancer"]
  union ["Diagnosis": "Able; Ulcerative Colitis"]
  union ["Diagnosis": "Able; Lower Gastrointestinal Bleeding"]
  union ["Diagnosis": "Able; Iron Deficiency Anemia"]
  union ["Diagnosis": "Able; Familial Adenomatous Polyposis"]
  union ["Diagnosis": "Able; Lynch Syndrome"]
  union ["Diagnosis": "Able; Inflammatory Bowel Disease"]

define "Performance Met":
  exists(["Procedure, Performed": "MIPS; Performance Met: G9659"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or not exists("Valid Condition for Colonoscopy" D
    with "Denominator Encounter" E
      such that D.prevalencePeriod starts during or before start of E.relevantPeriod)

define "Exception":
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9660"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G9659":
  /*
   * config_link_id: G9659
   */
  "Performance Met"
  and not "Exception"

define "Denominator Exception: G9660":
  /*
   * config_link_id: G9660
   */
  "Performance Met"
  and "Exception"

define "Numerator Performance Not Met: G9661":
  /*
   * config_link_id: G9661
   */
  not "Numerator Performance Met: G9659"
  and not "Denominator Exception: G9660"
