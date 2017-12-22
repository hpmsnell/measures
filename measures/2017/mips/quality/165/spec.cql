library MIPS_165_2017 version '1'

/*
 * Source: MIPS
 * ID: 165
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 165 Procedure"
valueset "MIPS; Performance Met: G8571"
valueset "MIPS; Performance Not Met: G8572"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 165 Procedure"] E
    where AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G8571":
  /*
   * config_link_id: G8571
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8571"] P
    with "Denominator Procedure" D
      such that P.relevantPeriod starts on or 30 days or less after start of D.relevantPeriod)

define "Numerator Performance Not Met: G8572":
  /*
   * config_link_id: G8572
   */
  not "Numerator Performance Met: G8571"
