library MIPS_195_2019 version '1'

/*
 * Source: MIPS
 * ID: 195
 * Year: 2019
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 195 Procedure"
valueset "MIPS; Performance Met: 3100F"
valueset "MIPS; Performance Not Met: 3100F-8P"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 195 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: 3100F":
  /*
   * config_link_id: 3100F
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: 3100F"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod

define "Numerator Performance Not Met: 3100F-8P":
  /*
   * config_link_id: 3100F-8P
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: 3100F-8P"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod

define "Numerator Performance Not Met: No Quality Data Code":
/*
* config_link_id: nodata
*/
not "Numerator Performance Met: 3100F"
and not "Numerator Performance Not Met: 3100F-8P"
