library MIPS_262_2017 version '1'

/*
 * Source: MIPS
 * ID: 262
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 262 Procedure"
valueset "MIPS; Breast Lesion"
valueset "MIPS; MIPS 262 Exclusion"
valueset "MIPS; Performance Met: G8872"
valueset "MIPS; Performance Not Met: G8874"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 262 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Breast Lesion"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; MIPS 262 Exclusion"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Met: G8872":
  /*
   * config_link_id: G8872
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8872"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G8874":
  /*
   * config_link_id: G8874
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G8872"
