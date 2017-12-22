library MIPS_167_2017 version '1'

/*
 * Source: MIPS
 * ID: 167
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 167 Procedure"
valueset "MIPS; Performance Met: G8575"
valueset "MIPS; Performance Not Met: G8576"
valueset "MIPS; Denominator Exclusion: G9722"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 167 Procedure"] E
    where AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: G9722"] P
    with "Denominator Procedure" D
      such that P.relevantPeriod starts during D.relevantPeriod)

define "Numerator Performance Met: G8575":
  /*
   * config_link_id: G8575
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8575"] P
    with "Denominator Procedure" D
      such that P.relevantPeriod starts during D.relevantPeriod)

define "Numerator Performance Not Met: G8576":
  /*
   * config_link_id: G8576
   */
  not "Numerator Performance Met: G8575"
