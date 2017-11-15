library MIPS_363_2017 version '1'

/*
 * Source: MIPS
 * ID: 363
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 363 Procedure"
valueset "MIPS; Performance Met: G9341"
valueset "MIPS; Denominator Exception: G9344"
valueset "MIPS; Denominator Exception: G9753"
valueset "MIPS; Performance Not Met: G9342"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 363 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9341":
  /*
   * config_link_id: G9341
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9341"] P
    with "Denominator Procedure" D
      such that P.relevantPeriod starts during D.relevantPeriod)

define "Denominator Exception: G9344":
  /*
   * config_link_id: G9344
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9344"] P
    with "Denominator Procedure" D
      such that P.relevantPeriod starts during D.relevantPeriod)

define "Denominator Exception: G9753":
  /*
   * config_link_id: G9344
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9753"] P
    with "Denominator Procedure" D
      such that P.relevantPeriod starts during D.relevantPeriod)

define "Numerator Performance Not Met: G9342":
  /*
   * config_link_id: G9342
   */
  not "Numerator Performance Met: G9341"
  and not "Denominator Exception: G9344"
  and not "Denominator Exception: G9753"
