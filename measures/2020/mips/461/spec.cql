library MIPS_461_RATE_1_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 461
 * Year: 2020
 * Version: 1
 * Written by: Patrick Clark
 *
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 461 Procedure"
valueset "MIPS; Herniated Disc"
valueset "MIPS; Other Spine Procedure"
valueset "MIPS; Lumbar Spine Region Cancer"
valueset "MIPS; Lumbar Spine Region Fracture"
valueset "MIPS; Lumbar Spine Region Infection"
valueset "MIPS; Lumbar Idiopathic or Congenital Scoliosis"
valueset "MIPS; Performance Met: G2140"
valueset "MIPS; Performance Not Met: G9949"
valueset "MIPS; Performance Not Met: G2141"
// Able value sets

valueset "Able; Other Spine Procedure"
valueset "Able; Leg Visual Analog Scale"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 461 Procedure"] E
    where E.relevantPeriod starts during [1 year before start of "Measurement Period", 1 year before end of "Measurement Period"]
      and AgeInYearsAt(1 year before start of "Measurement Period") >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Excluded Diagnosis":
  ["Diagnosis": "MIPS; Lumbar Spine Region Cancer"]
    union ["Diagnosis": "MIPS; Lumbar Spine Region Fracture"]
    union ["Diagnosis": "MIPS; Lumbar Spine Region Infection"]
    union ["Diagnosis": "MIPS; Lumbar Idiopathic or Congenital Scoliosis"]

define "Preoperative Leg Visual Analog Scale Result":
  ["Procedure, Performed": "Able; Leg Visual Analog Scale"] A
    with "Denominator Encounter" E
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod
    return A.result

define "Postoperative Leg Visual Analog Scale Result":
  ["Procedure, Performed": "Able; Leg Visual Analog Scale"] A
    with "Denominator Encounter" E
      such that A.authorDateTime during [6 weeks after start of E.relevantPeriod, 20 weeks after start of E.relevantPeriod]]
    return A.result

    /* Populations */

define "Denominator":
    "Denominator Encounter"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Other Spine Procedure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during of E.relevantPeriod)
  exists(["Procedure, Performed": "Able; Other Spine Procedure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during of E.relevantPeriod)


define "Denominator Exclusion Lumbar":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Procedure, Performed": "MIPS; Lumbar Disorder"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
    or exists("Excluded Diagnosis" D
      with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Met: G2140":
  /*
   * config_link_id: G2140
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2140"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod)
    or "Postoperative Leg Visual Analog Scale Result" <= 3
    or "Preoperative Leg Visual Analog Scale Result" - "Postoperative Leg Visual Analog Scale Result" >= 5

define "Numerator Performance Not Met: G2141":
      /*
      * config_link_id: G2141
      */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G2141"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod)
  or (
    "Postoperative Leg Visual Analog Scale Result" > 3
    and "Preoperative Leg Visual Analog Scale Result" - "Postoperative Leg Visual Analog Scale Result" < 5)

define "Numerator Performance Not Met: G9949":
      /*
       * config_link_id: G9949
       */
  not "Denominator Exclusion"
  and not "Denominator Exclusion Lumbar"
  and not "Numerator Performance Met: G2140"
  and not "MIPS; Performance Not Met: G2141"
