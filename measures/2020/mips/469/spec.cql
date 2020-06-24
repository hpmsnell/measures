library MIPS_469_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 469 Rate 1
 * Year: 2020
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 469 Procedure"
valueset "MIPS; Lumbar Disorder"
valueset "MIPS; Lumbar Spine Region Cancer"
valueset "MIPS; Lumbar Spine Region Fracture"
valueset "MIPS; Lumbar Spine Region Infection"
valueset "MIPS; Lumbar Idiopathic or Congenital Scoliosis"
valueset "MIPS; Performance Met: G2142"
valueset "MIPS; Performance Not Met: G2143"
valueset "MIPS; Performance Not Met: M1043"

// Able value sets

valueset "Able; Oswestry Disability Index"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 469 Procedure"] E
    where E.relevantPeriod starts during [15 months before start of "Measurement Period", 15 months before end of "Measurement Period"]
      and AgeInYearsAt(15 months before start of "Measurement Period") >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Excluded Diagnosis":
  ["Diagnosis": "MIPS; Lumbar Spine Region Cancer"]
  union ["Diagnosis": "MIPS; Lumbar Spine Region Fracture"]
  union ["Diagnosis": "MIPS; Lumbar Spine Region Infection"]
  union ["Diagnosis": "MIPS; Lumbar Idiopathic or Congenital Scoliosis"]

define "Preoperative Oswestry Disability Index Result":
  ["Procedure, Performed": "Able; Oswestry Disability Index"] A
    with "Denominator Encounter" E
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod
    return A.result

define "Postoperative Oswestry Disability Index Result":
  ["Procedure, Performed": "Able; Oswestry Disability Index"] A
    with "Denominator Encounter" E
      such that A.authorDateTime during [6 weeks after start of E.relevantPeriod, 20 weeks after start of E.relevantPeriod]
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

define "Numerator Performance Met: G2142":
  /*
   * config_link_id: G2142
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2142"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod)
  or "Postoperative Oswestry Disability Index Result" <= 22
  or "Preoperative Oswestry Disability Index Result" - "Postoperative Oswestry Disability Index Result" >= 30

define "Numerator Performance Not Met: G2143":
  /*
  * config_link_id: G2143
  */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G2143"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod)
  or (
    "Postoperative Oswestry Disability Index Result" > 22
    and "Preoperative Oswestry Disability Index Result" - "Postoperative Oswestry Disability Index Result" < 30
  )

define "Numerator Performance Not Met: M1043":
  /*
   * config_link_id: M1043
   */
  not "Denominator Exclusion: Spine Procedure"
  and not "Denominator Exclusion: Diagonsis"
  and not "Numerator Performance Met: G2142"
  and not "Numerator Performance Met: G2143"
