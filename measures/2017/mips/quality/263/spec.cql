library MIPS_263_2017 version '1'

/*
 * Source: MIPS
 * ID: 263
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 263 Procedure"
valueset "MIPS; MIPS 263 Breast Cancer"
valueset "MIPS; MIPS 263 Exclusion"
valueset "MIPS; Performance Met: G8875"
valueset "MIPS; Denominator Exception: G8876"
valueset "MIPS; Performance Not Met: G8877"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 263 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; MIPS 263 Breast Cancer"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; MIPS 263 Exclusion"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Met: G8875":
  /*
   * config_link_id: G8875
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8875"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: G8876":
  /*
   * config_link_id: G8876
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G8876"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G8877":
  /*
   * config_link_id: G8877
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G8875"
  and not "Denominator Exception: G8876"
