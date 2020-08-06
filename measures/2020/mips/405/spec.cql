library MIPS_405_2020 version '1'

/*
 * Source: MIPS
 * ID: 405
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 405 Procedure"
valueset "MIPS; MIPS 405 Incidental Finding"
valueset "MIPS; Performance Met: G9548"
valueset "MIPS; Denominator Exception: G9549"
valueset "MIPS; Performance Not Met: G9550"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 405 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Procedure, Performed": "MIPS; MIPS 405 Incidental Finding"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9548":
  /*
   * config_link_id: G9548
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9548"] P1 // 2020 follow up not recomended
      such that P1.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: G9549":
  /*
   * config_link_id: G9549
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Denomiantor Exception: G9549"] P2 // 2020 followup recomended due to  lymphadenopathy or cancer
      such that P2.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G9550":
  /*
   * config_link_id: G9550
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: G9550"] P1 // 2020 followup recomended
      such that P1.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: No Quality Data Code":
/*
* config_link_id: nodata
*/
not "Numerator Performance Met: G9548"
and not "Denominator Exception: G9549"
and not "Numerator Performance Not Met: G9550"
