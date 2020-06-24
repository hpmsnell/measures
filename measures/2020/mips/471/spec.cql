library MIPS_471_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 471 Rate 1
 * Year: 2020
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 471 Procedure"
valueset "MIPS; Herniated Disc"
valueset "MIPS; Other Spine Procedure"
valueset "MIPS; Denominator Exclusion: G9945"
valueset "MIPS; Denominator Exclusion: M1051"
valueset "MIPS; Lumbar Spine Region Cancer"
valueset "MIPS; Lumbar Spine Region Fracture"
valueset "MIPS; Lumbar Spine Region Infection"
valueset "MIPS; Lumbar Idiopathic or Congenital Scoliosis"
valueset "MIPS; Performance Met: G2144"
valueset "MIPS; Performance Not Met: G2145"
valueset "MIPS; Performance Not Met: M1049"

// Able value sets

valueset "Able; Other Spine Procedure"
valueset "Able; Oswestry Disability Index"

parameter "Measurement Period" Interval<DateTime>

context Patient

/* Definitions */

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 471 Procedure"] E
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

define "Denominator Exclusion Diagnosis":
  /*
   * config_link_id: exclusion_diagnosis
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: G9945"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists(["Procedure, Performed": "MIPS; Denominator Exclusion: M1051"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Excluded Diagnosis" D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Met: G2144":
  /*
   * config_link_id: G2144
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2144"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod)
  or "Postoperative Oswestry Disability Index Result" <= 22
  or "Preoperative Oswestry Disability Index Result" - "Postoperative Oswestry Disability Index Result" >= 30

define "Numerator Performance Not Met: G2145":
  /*
  * config_link_id: G2145
  */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G2145"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod)
  or (
    "Postoperative Oswestry Disability Index Result" > 22
    and "Preoperative Oswestry Disability Index Result" - "Postoperative Oswestry Disability Index Result" < 30
  )

define "Numerator Performance Not Met: M1049":
  /*
   * config_link_id: M1049
   */
  not "Denominator Exclusion: Spine Procedure"
  and not "Denominator Exclusion: Diagonsis"
  and not "Numerator Performance Met: G2144"
  and not "Numerator Performance Met: G2145"
