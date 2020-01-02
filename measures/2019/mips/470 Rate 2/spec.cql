library MIPS_470_RATE_2_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 470 Rate 2
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 470 Procedure"
valueset "MIPS; Performance Met: M1045"

// Able value sets

valueset "Able; Oxford Knee Score"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 470 Procedure"] E
    where E.relevantPeriod starts during [15 months before start of "Measurement Period", 15 months before end of "Measurement Period"]
      and AgeInYearsAt(15 months before start of "Measurement Period") >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Denominator Encounter with Exam":
  "Denominator Encounter" E
    with ["Procedure, Performed": "Able; Oxford Knee Score"] A1
      such that such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod
    with ["Procedure, Performed": "Able; Oxford Knee Score"] A2
      such that A.authorDateTime during [9 months after start of E.relevantPeriod, 15 months after start of E.relevantPeriod]
  union "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: M1045"] P
      such that P.relevantPeriod starts on or 15 weeks or less after start of E.relevantPeriod

define "Preoperative Result":
  ["Assessment, Performed": "Able; Oxford Knee Score"] A
    where not A.result = null
    with "Denominator Encounter" E
      such that such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod
    return A.result

define "Postoperative Result":
  ["Assessment, Performed": "Able; Oxford Knee Score"] A
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

define "Numerator":
  /*
   * config_link_id: numerator
   */
  "Highest Preoperative Result" - "Lowest Postoperative Result"
