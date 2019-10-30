library MIPS_145_2019 version '1'

/*
 * Source: MIPS
 * ID: 145
 * Year: 2019
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 145 Encounter"
valueset "MIPS; Performance Met: G9500"
valueset "MIPS; Performance Not Met: G9501"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 145 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G9500":
  /*
   * config_link_id: G9500
   */
  "Denominator Encounter" E
    with ["Encounter, Performed": "MIPS; Performance Met: G9500"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod

define "Numerator Performance Not Met: G9501":
  /*
   * config_link_id: G9501
   */
  "Denominator Encounter" E
    with ["Encounter, Performed": "MIPS; Performance Not Met: G9501"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod

define "Numerator Performance Not Met: No Quality Data Code":
/*
* config_link_id: nodata
*/
not "Numerator Performance Met: G9500"
and not "Numerator Performance Not Met: G9501"
