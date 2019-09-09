library MIPS_364_2019 version '1'

/*
 * Source: MIPS
 * ID: 364
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 364 Procedure"
valueset "MIPS; Incidental Pulmonary Nodule"
valueset "MIPS; Denominator Exclusion: M1018"
valueset "MIPS; Performance Met: G9345"
valueset "MIPS; Denominator Exception: G9755"
valueset "MIPS; Performance Not Met: G9347"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 364 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 35
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Incidental Pulmonary Nodule"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: M1018":
  /*
   * config_link_id: M1018
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Denominator Exclusion: M1018"] P
      such that P.relevantPeriod starts on or before end of "Measurement Period"

define "Numerator Performance Met: G9345":
  /*
   * config_link_id: G9345
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9345"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: G9755":
  /*
   * config_link_id: G9755
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Denomiantor Exception: G9755"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G9347":
  /*
   * config_link_id: G9347
   */
  not "Numerator Performance Met: G9345"
  and not "Denominator Exception: G9755"
