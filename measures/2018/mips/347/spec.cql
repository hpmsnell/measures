library MIPS_347_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 347
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 347 Procedure"
valueset "MIPS; Infrarenal Non-Ruptured AAA"
valueset "MIPS; Denominator Exclusion: 9003F"
valueset "MIPS; Denominator Exclusion: 9004F"
valueset "MIPS; Performance Not Met: G9963"
valueset "MIPS; Performance Met: G9262"

// Able value sets

valueset "Able; Death in Hospital"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 347 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Infrarenal Non-Ruptured AAA"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Death":
  ["Diagnosis": "VSAC; Death in Hospital"
  union ["Procedure, Performed": "MIPS; Performance Met: G9262"]

/* Populations */

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: 9003F"] P
    where "Patient Characteristic Sex" in "Female"
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: 9004F"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G9263":
  /*
   * config_link_id: G9263
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9263"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or not exists("Death in Hospital" D
    with "Denominator Procedure" D
      such that D.prevalencePeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9262":
  /*
   * config_link_id: G9262
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G9263"
