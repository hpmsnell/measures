library MIPS_352_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 352
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 352 Procedure"
valueset "MIPS; Performance Met: G9301"
valueset "MIPS; Denominator Exception: G9300"
valueset "MIPS; Performance Not Met: G9302"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 352 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9301":
  /*
   * config_link_id: G9301
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9301"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Denominator Exception: G9300":
  /*
   * config_link_id: G9300
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9300"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9302":
  /*
   * config_link_id: G9302
   */
  not "Numerator Performance Met: G9301"
  and not "Denominator Exception: G9300"
