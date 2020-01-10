library MIPS_469_RATE_1_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 469 Rate 1
 * Year: 2019
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
valueset "MIPS; Performance Met: M1042"
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

define "Oswestry Disability Index Exists":
  exists(["Procedure, Performed": "Able; Oswestry Disability Index"] A
    with "Denominator Encounter" E
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod)
  and exists(["Procedure, Performed": "Able; Oswestry Disability Index"] A
    with "Denominator Encounter" E
      such that A.authorDateTime during [9 months after start of E.relevantPeriod, 15 months after start of E.relevantPeriod])

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

define "Numerator Performance Met: M1042":
  /*
   * config_link_id: M1042
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: M1042"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 15 weeks or less after start of E.relevantPeriod)
  or "Oswestry Disability Index Exists"

define "Numerator Performance Not Met: M1043":
  /*
   * config_link_id: M1043
   */
  not "Denominator Exclusion
  and not "Numerator Performance Met: M1042"
