library MIPS_360_2018 version '1'

/*
 * Source: MIPS
 * ID: 360
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 360 Procedure"
valueset "MIPS; Performance Met: G9321"
valueset "MIPS; Performance Not Met: G9322"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 360 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9321":
  /*
   * config_link_id: G9321
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9321"] P
    with "Denominator Procedure" D
      such that P.relevantPeriod starts during D.relevantPeriod)

define "Numerator Performance Not Met: G9322":
  /*
   * config_link_id: G9322
   */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G9322"] P
    with "Denominator Procedure" D
      such that P.relevantPeriod starts during D.relevantPeriod)

define "Numerator Performance Not Met: No Data":
  /*
   * config_link_id: nodata
   */
  not "Numerator Performance Met: G9321"
  and not "Numerator Performance Not Met: G9322"
