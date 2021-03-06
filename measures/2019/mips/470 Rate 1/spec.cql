library MIPS_470_RATE_1_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 470 Rate 1
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 470 Procedure"
valueset "MIPS; Performance Met: M1045"
valueset "MIPS; Performance Not Met: M1046"

// Able value sets

valueset "Able; Oxford Knee Score"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 470 Procedure"] E
    where E.relevantPeriod starts during [15 months before start of "Measurement Period", 15 months before end of "Measurement Period"]
      and AgeInYearsAt(15 months before start of "Measurement Period") >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Oxford Knee Score Exists":
  exists(["Procedure, Performed": "Able; Oxford Knee Score"] A
    with "Denominator Encounter" E
      such that A.authorDateTime on or 3 months or less before start of E.relevantPeriod)
  and exists(["Procedure, Performed": "Able; Oxford Knee Score"] A
    with "Denominator Encounter" E
      such that A.authorDateTime during [9 months after start of E.relevantPeriod, 15 months after start of E.relevantPeriod])

/* POPULATIONS */

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: M1045":
  /*
   * config_link_id: M1045
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: M1045"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 15 weeks or less after start of E.relevantPeriod)
  or "Oxford Knee Score Exists"

define "Numerator Performance Not Met: M1046":
  /*
   * config_link_id: M1046
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: M1045"
