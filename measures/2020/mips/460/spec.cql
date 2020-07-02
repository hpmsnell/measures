library MIPS_460_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 460
 * Year: 2020
 * Version: 1
 * Written by: Patrick Clark
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 460 Procedure"
valueset "MIPS; Lumbar Disorder"
valueset "MIPS; Lumbar Spine Region Cancer"
valueset "MIPS; Lumbar Spine Region Fracture"
valueset "MIPS; Lumbar Spine Region Infection"
valueset "MIPS; Lumbar Idiopathic or Congenital Scoliosis"
valueset "MIPS; Performance Met: G2138"
valueset "MIPS; Performance Not Met: G2139"
valueset "MIPS; Performance Not Met: G9946"

// Able value sets

valueset "Able; Back Visual Analog Scale"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 460 Procedure"] E
    where E.relevantPeriod starts during [15 months before start of "Measurement Period", 15 months before end of "Measurement Period"]
      and AgeInYearsAt(15 months before start of "Measurement Period") >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Excluded Diagnosis":
  ["Diagnosis": "MIPS; Lumbar Spine Region Cancer"]
  union ["Diagnosis": "MIPS; Lumbar Spine Region Fracture"]
  union ["Diagnosis": "MIPS; Lumbar Spine Region Infection"]
  union ["Diagnosis": "MIPS; Lumbar Idiopathic or Congenital Scoliosis"]

define "Preoperative Back Visual Analog Scale Result":
  ["Procedure, Performed": "Able; Back Visual Analog Scale"] A
    with "Denominator Encounter" E
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod
    return A.result

define "Postoperative Back Visual Analog Scale Result":
  ["Procedure, Performed": "Able; Back Visual Analog Scale"] A
    with "Denominator Encounter" E
      such that A.authorDateTime during [9 months after start of E.relevantPeriod, 15 months after start of E.relevantPeriod]]
    return A.result

    /* Populations */

    define "Denominator":
      "Denominator Encounter"

    define "Denominator Exclusion":
      /*
       * config_link_id: exclusion_1
       */
      exists(["Procedure, Performed": "MIPS; Lumbar Disorder"] P
        with "Denominator Encounter" E
          such that P.relevantPeriod starts during E.relevantPeriod)
      or exists("Excluded Diagnosis" D
        with "Denominator Encounter" E
          such that D.prevalencePeriod overlaps E.relevantPeriod)


    define "Numerator Performance Met: G2138":
      /*
       * config_link_id: G2138
       */
      exists(["Procedure, Performed": "MIPS; Performance Met: G2138"] P
        with "Denominator Encounter" E
          such that P.relevantPeriod starts on or 15 months or less after start of E.relevantPeriod)
      or "Postoperative Back Visual Analog Scale Result" <= 3
      or "Preoperative Back Visual Analog Scale Result" - "Postoperative Back Visual Analog Scale Result" >= 5

    define "Numerator Performance Not Met: G2139":
      /*
      * config_link_id: G2139
      */
      exists(["Procedure, Performed": "MIPS; Performance Not Met: G2139"] P
        with "Denominator Encounter" E
          such that P.relevantPeriod starts on or 15 months or less after start of E.relevantPeriod)
      or (
        "Postoperative Back Visual Analog Scale Result" > 3
        and "Preoperative Back Visual Analog Scale Result" - "Postoperative Back Visual Analog Scale Result" < 5)

    define "Numerator Performance Not Met: G9946":
      /*
       * config_link_id: G9943
       */
      not "Denominator Exclusion"
      and not "Numerator Performance Met: G2138"
      and not "Numerator Performance Not Met: G2139"
