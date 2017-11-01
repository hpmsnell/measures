library MIPS_353_2017 version '1'

/*
 * Source: MIPS
 * ID: 353
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 353 Procedure"
valueset "MIPS; Performance Met: G9304"
valueset "MIPS; Performance Not Met: G9303"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 353 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9304":
  /*
   * config_link_id: G9304
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9304"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G9303":
  /*
   * config_link_id: G9303
   */
  not "Numerator Performance Met: G9304"
