library MIPS_461_RATE_2_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 461 Rate 2
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 461 Procedure"
valueset "MIPS; Herniated Disc"
valueset "MIPS; Other Spine Procedure"
valueset "MIPS; Performance Met: G9947"

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
    with ["Diagnosis": "MIPS; Herniated Disc"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator Encounter with Exam":
  "Denominator Encounter" E
    with ["Procedure, Performed": "Able; Leg Visual Analog Scale"] A1
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod
    with ["Procedure, Performed": "Able; Leg Visual Analog Scale"] A2
      such that A.authorDateTime during [6 weeks after start of E.relevantPeriod, 20 weeks after start of E.relevantPeriod]
  union "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9947"] P
      such that P.relevantPeriod starts on or 20 weeks or less after start of E.relevantPeriod

define "Preoperative Result":
  ["Assessment, Performed": "Able; Leg Visual Analog Scale"] A
    where not A.result = null
    with "Denominator Encounter" E
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod
    return A.result

define "Postoperative Result":
  ["Assessment, Performed": "Able; Leg Visual Analog Scale"] A
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
    without ["Procedure, Performed": "MIPS; Other Spine Procedure"] P1
      such that P1.relevantPeriod starts during E.relevantPeriod
    without ["Procedure, Performed": "Able; Other Spine Procedure"] P2
      such that P2.relevantPeriod starts during E.relevantPeriod

define "Numerator":
  /*
   * config_link_id: numerator
   */
  "Highest Preoperative Result" - "Lowest Postoperative Result"
