library MIPS_406_2019 version '1'

/*
 * Source: MIPS
 * ID: 406
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 406 Procedure"
valueset "MIPS; MIPS 406 Incidental Finding"
valueset "MIPS; Performance Met: G9554"
valueset "MIPS; Denominator Exception: G9555"
valueset "MIPS; Performance Not Met: G9556"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 406 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Procedure, Performed": "MIPS; MIPS 406 Incidental Finding"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9554":
  /*
   * config_link_id: G9554
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9554"] P
      such that P.relevantPeriod starts during E.relevantPeriod
    without ["Procedure, Performed": "MIPS; Denomiantor Exception: G9555"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: G9555":
  /*
   * config_link_id: G9555
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9554"] P
      such that P.relevantPeriod starts during E.relevantPeriod
    with ["Procedure, Performed": "MIPS; Denomiantor Exception: G9555"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G9556":
  /*
   * config_link_id: G9556
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: G9556"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: No Quality Data Code":
/*
* config_link_id: nodata
*/
not "Numerator Performance Met: G9554"
and not "Denominator Exception: G9555"
and not "Numerator Performance Not Met: G9556"
