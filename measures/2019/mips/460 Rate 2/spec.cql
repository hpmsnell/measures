library MIPS_460_RATE_2_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 460 Rate 2
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
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
valueset "MIPS; Performance Met: G9944"

// Able value sets

valueset "Able; Back Visual Analog Scale"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 460 Procedure"] E
    where E.relevantPeriod starts during [15 months before start of "Measurement Period", 15 months before end of "Measurement Period"]
      and AgeInYearsAt(15 months before start of "Measurement Period") >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Denominator Encounter with Exam":
  "Denominator Encounter" E
    with ["Procedure, Performed": "Able; Back Visual Analog Scale"] A1
      such that A1.authorDateTime on or 3 months or less before start of E.relevantPeriod
    with ["Procedure, Performed": "Able; Back Visual Analog Scale"] A2
      such that A2.authorDateTime during [9 months after start of E.relevantPeriod, 15 months after start of E.relevantPeriod]
  union "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9944"] P
      such that P.relevantPeriod starts on or 15 months or less after start of E.relevantPeriod

define "Preoperative Result":
  ["Assessment, Performed": "Able; Back Visual Analog Scale"] A
    where not A.result = null
    with "Denominator Encounter" E
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod
    return A.result

define "Postoperative Result":
  ["Assessment, Performed": "Able; Back Visual Analog Scale"] A
    where not A.result = null
    with "Denominator Encounter" E
      such that A.authorDateTime during [9 months after start of E.relevantPeriod, 15 months after start of E.relevantPeriod]
    return A.result

define "Highest Preoperative Result":
  Last("Preoperative Result" R
    sort by R asc)

define "Lowest Postoperative Result":
  First("Postoperative Result" R
    sort by R asc)

/* Populations */

define "Denominator":
  "Denominator Encounter with Exam"
    without ["Procedure, Performed": "MIPS; Lumbar Disorder"] P
      such that P.relevantPeriod starts during E.relevantPeriod
    without "Excluded Diagnosis" D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Numerator":
  /*
   * config_link_id: numerator
   */
  "Highest Preoperative Result" - "Lowest Postoperative Result"
