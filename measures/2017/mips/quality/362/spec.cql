library MIPS_362_2017 version '1'

/*
 * Source: MIPS
 * ID: 362
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 362 Procedure"
valueset "MIPS; Performance Met: G9340"
valueset "MIPS; Performance Not Met: G9329"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 362 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9340":
  /*
   * config_link_id: G9340
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9340"] P
    with "Denominator Procedure" D
      such that P.relevantPeriod starts during D.relevantPeriod)

define "Numerator Performance Not Met: G9329":
  /*
   * config_link_id: G9329
   */
  not "Numerator Performance Met: G9340"
