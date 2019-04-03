library MIPS_390_2018 version '1'

/*
 * Source: MIPS
 * ID: 390
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 390 Encounter"
valueset "MIPS; MIPS 390 Chronic Hepatitis C"
valueset "MIPS; Performance Met: G9399"
valueset "MIPS; Denominator Exception: G9400"
valueset "MIPS; Performance Not Met: G9401"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 390 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; MIPS 390 Chronic Hepatitis C"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

/* POPULATIONS */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G9399":
  /*
   * config_link_id: G9399
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9399"] P
    where P.relevantPeriod starts before end of "Measurement Period"

define "Denominator Exception: G9400":
  /*
   * config_link_id: G9400
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9400"] P
    where P.relevantPeriod  starts before end of "Measurement Period"

define "Numerator Performance Not Met: G9401":
 /*
  * config_link_id: G9401
  */
 not "Numerator Performance Met: G9399"
 and not "Denominator Exception: G9400"
