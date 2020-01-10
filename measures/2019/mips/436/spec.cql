library MIPS_436_2017 version '1'

/*
 * Source: MIPS
 * ID: 436
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 436 Procedure"
valueset "MIPS; Performance Met: G9637"
valueset "MIPS; Performance Not Met: G9638"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 436 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9637":
  /*
   * config_link_id: G9637
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9637"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod

define "Numerator Performance Not Met: G9638":
  /*
   * config_link_id: G9638
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: G9638"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod

define "Numerator Performance Not Met: No Quality Data Code":
/*
* config_link_id: nodata
*/
not "Numerator Performance Met: G9554"
and not "Numerator Performance Not Met: G9638"
