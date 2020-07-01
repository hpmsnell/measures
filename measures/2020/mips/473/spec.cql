library MIPS_473_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 473
 * Year: 2020
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 473 Encounter"
valueset "MIPS; Lumbar Disorder"
valueset "MIPS; Lumbar Spine Region Cancer"
valueset "MIPS; Lumbar Spine Region Fracture"
valueset "MIPS; Lumbar Spine Region Infection"
valueset "MIPS; Lumbar Idiopathic or Congenital Scoliosis"
valueset "MIPS; Performance Met: G2146"
valueset "MIPS; Performance Not Met: G2147"
valueset "MIPS; Performance Not Met: M1052"

// Able value sets

valueset "Able; Leg Visual Analog Scale"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 473 Encounter"] E
    where E.relevantPeriod starts during [15 months before start of "Measurement Period", 15 months before end of "Measurement Period"]
      and AgeInYearsAt(15 months before start of "Measurement Period") >= 18
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
      such that A.authorDateTime during [9 months after start of E.relevantPeriod, 15 months after start of E.relevantPeriod]
    return A.result

/* POPULATIONS */

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

define "Numerator Performance Met: G2146":
  /*
   * config_link_id: G2146
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2146"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 15 weeks or less after start of E.relevantPeriod)
  or "Postoperative Leg Visual Analog Scale Result" <= 3
  or "Preoperative Leg Visual Analog Scale Result" - "Postoperative Leg Visual Analog Scale Result" >= 5

define "Numerator Performance Not Met: G2147":
  /*
  * config_link_id: G2147
  */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G2147"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 15 weeks or less after start of E.relevantPeriod)
  or (
    "Postoperative Leg Visual Analog Scale Result" > 3
    and "Preoperative Leg Visual Analog Scale Result" - "Postoperative Leg Visual Analog Scale Result" < 5
  )

define "Numerator Performance Not Met: M1052":
  /*
   * config_link_id: M1052
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G2146"
  and not "Numerator Performance Met: G2147"
