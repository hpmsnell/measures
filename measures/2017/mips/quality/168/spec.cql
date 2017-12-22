library MIPS_168_2017 version '1'

/*
 * Source: MIPS
 * ID: 168
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 168 Procedure"
valueset "MIPS; Performance Met: G8677"
valueset "MIPS; Performance Not Met: G8678"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 168 Procedure"] E
    where AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G8677":
  /*
   * config_link_id: G8677
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8677"] P
    with "Denominator Procedure" D
      such that P.relevantPeriod starts during D.relevantPeriod)

define "Numerator Performance Not Met: G8678":
  /*
   * config_link_id: G8678
   */
  not "Numerator Performance Met: G8677"
