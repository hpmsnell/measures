library MIPS_389_2018 version '1'

/*
 * Source: MIPS
 * ID: 389
 * Year: 2018
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 389 Procedure"
valueset "MIPS; Performance Met: G9519"
valueset "MIPS; Denominator Exception: G0914"
valueset "MIPS; Performance Not Met: G9520"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 389 Procedure"] P
    where P.relevantPeriod starts during Interval[start of "Measurement Period", 3 months before end "Measurement Period"]
      and P.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P.relevantPeriod) >= 18
      and not P.code.modifier in {55, 56}
      and P.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9519":
  /*
   * config_link_id: G9519
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9519"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 90 days or less after start of E.relevantPeriod)

define "Numerator Performance Met: G0914":
  /*
   * config_link_id: G0914
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G0914"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 90 days or less after start of E.relevantPeriod)

define "Numerator Performance Not Met: G9520":
  /*
   * config_link_id: G9520
   */
  not "Numerator Performance Met: G9519"
  and not "Denominator Exception: G0914"
