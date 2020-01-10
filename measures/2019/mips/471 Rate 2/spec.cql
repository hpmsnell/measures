library MIPS_471_RATE_2_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 471 Rate 2
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 471 Procedure"
valueset "MIPS; Herniated Disc"
valueset "MIPS; Other Spine Procedure"
valueset "MIPS; Performance Met: M1048"

// Able value sets

valueset "Able; Other Spine Procedure"
valueset "Able; Oswestry Disability Index"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 471 Procedure"] E
    where E.relevantPeriod starts during [1 year before start of "Measurement Period", 1 year before end of "Measurement Period"]
      and AgeInYearsAt(1 year before start of "Measurement Period") >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Herniated Disc"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator Encounter with Exam":
  "Denominator Encounter" E
    with ["Procedure, Performed": "Able; Oswestry Disability Index"] A1
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod
    with ["Procedure, Performed": "Able; Oswestry Disability Index"] A2
      such that A.authorDateTime during [6 weeks after start of E.relevantPeriod, 20 weeks after start of E.relevantPeriod]
  union "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: M1048"] P
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod

define "Excluded Procedure":
  ["Procedure, Performed": "MIPS; Other Spine Procedure"]
  union ["Procedure, Performed": "Able; Other Spine Procedure"]

define "Preoperative Result":
  ["Assessment, Performed": "Able; Oswestry Disability Index"] A
    where not A.result = null
    with "Denominator Encounter" E
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod
    return A.result

define "Postoperative Result":
  ["Assessment, Performed": "Able; Oswestry Disability Index"] A
    where not A.result = null
    with "Denominator Encounter" E
      such that A.authorDateTime during [6 weeks after start of E.relevantPeriod, 20 weeks after start of E.relevantPeriod]
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
    without "Excluded Procedure" P
      such that P.prevalencePeriod starts during E.relevantPeriod)

define "Numerator":
  /*
   * config_link_id: numerator
   */
  "Highest Preoperative Result" - "Lowest Postoperative Result"
