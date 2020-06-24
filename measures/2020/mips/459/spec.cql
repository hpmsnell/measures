library MIPS_459_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 459
 * Year: 2020
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 459 Procedure"
valueset "MIPS; Herniated Disc"
valueset "MIPS; Other Spine Procedure"
valueset "MIPS; Denominator Exclusion: G9945"
valueset "MIPS; Lumbar Spine Region Cancer"
valueset "MIPS; Lumbar Spine Region Fracture"
valueset "MIPS; Lumbar Spine Region Infection"
valueset "MIPS; Lumbar Idiopathic or Congenital Scoliosis"
valueset "MIPS; Performance Met: G2136"
valueset "MIPS; Performance Not Met: G2137"
valueset "MIPS; Performance Not Met: G9943"

// Able value sets

valueset "Able; Other Spine Procedure"
valueset "Able; Back Visual Analog Scale"

parameter "Measurement Period" Interval<DateTime>

context Patient

/* Definitions */

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 459 Procedure"] E
    where E.relevantPeriod starts during [1 year before start of "Measurement Period", 1 year before end of "Measurement Period"]
      and AgeInYearsAt(1 year before start of "Measurement Period") >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Herniated Disc"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

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
      such that A.authorDateTime during [6 weeks after start of E.relevantPeriod, 20 weeks after start of E.relevantPeriod]]
    return A.result

/* Populations */

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion: Spine Procedure":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Other Spine Procedure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists(["Procedure, Performed": "Able; Other Spine Procedure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exclusion: Diagnosis":
  /*
   * config_link_id: exclusion_diagnosis
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: G9945"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Excluded Diagnosis" D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Met: G2136":
  /*
   * config_link_id: G2136
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2136"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod)
  or "Postoperative Back Visual Analog Scale Result" <= 3
  or "Preoperative Back Visual Analog Scale Result" - "Postoperative Back Visual Analog Scale Result" >= 5

define "Numerator Performance Not Met: G2137":
  /*
  * config_link_id: G2137
  */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G2137"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod)
  or (
    "Postoperative Back Visual Analog Scale Result" > 3
    and "Preoperative Back Visual Analog Scale Result" - "Postoperative Back Visual Analog Scale Result" < 5

define "Numerator Performance Not Met: G9943":
  /*
   * config_link_id: G9943
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G2136"
