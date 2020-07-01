library MIPS_470_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 470
 * Year: 2020
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 470 Procedure"
valueset "MIPS; Performance Met: M1045"
valueset "MIPS; Performance Not Met: M1141"
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

define "Postoperative Oxford Knee Scale Result":
  ["Procedure, Performed": "Able; Oxford Knee Score"] A
    with "Denominator Encounter" E
      such that A.authorDateTime during [9 months after start of E.relevantPeriod, 15 months after start of E.relevantPeriod]
    return A.result

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
  or "Postoperative Oxford Knee Score Result" >= 37

define "Numerator Performance Not Met: M1046":
  /*
   * config_link_id: M1046
   */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: M1046"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 15 weeks or less after start of E.relevantPeriod)
  or "Postoperative Oxford Knee Score Result" < 37

define "Numerator Performance Not Met: M1141":
  /*
   * config_link_id: M1141
   */
  not "Numerator Performance Met: M1045"
  and not not "Numerator Performance Not Met: M1046"
