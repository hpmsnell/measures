library MIPS_304_2017 version '1'

/*
 * Source: MIPS
 * ID: 304
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 304 Procedure"
valueset "MIPS; Performance Met: G0916"
valueset "MIPS; Denominator Exception: G0917"
valueset "MIPS; Performance Not Met: G0918"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 304 Procedure"] P
    where P.relevantPeriod starts during Interval[start of "Measurement Period", 3 months before end "Measurement Period"]
      and P.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of P.relevantPeriod) >= 18
      and not P.code.modifier in {55, 56}
      and P.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G0916":
  /*
   * config_link_id: G0916
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G0916"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 90 days or less after start of E.relevantPeriod)

define "Denominator Exception: G0917":
  /*
   * config_link_id: G0917
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G0917"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 90 days or less after start of E.relevantPeriod)

define "Numerator Performance Not Met: G0918":
  /*
   * config_link_id: G0918
   */
  not "Numerator Performance Met: G0916"
  and not "Denominator Exception: G0917"
