library MIPS_355_2017 version '1'

/*
 * Source: MIPS
 * ID: 355
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 355 Procedure"
valueset "MIPS; MIPS 355 Reoperation"
valueset "MIPS; Performance Met: G9308"
valueset "MIPS; Performance Not Met: G9307"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Encounter Interval":
  Interval[start of "Measurement Period", end of "Measurement Period" - 1 month]

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 355 Procedure"] P
    where P.relevantPeriod starts during "Encounter Interval"
      and P.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9308":
  /*
   * config_link_id: G9308
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9308"] P
    with "Denominator Procedure" P
      where R.relevantPeriod starts 30 days or less after end of P.relevantPeriod)
  or exists(["Procedure, Performed": "MIPS; MIPS 355 Reoperation"] R
    with "Denominator Procedure" P
      where R.relevantPeriod starts 30 days or less after end of P.relevantPeriod)

define "Numerator Performance Not Met: G9307":
  /*
   * config_link_id: G9307
   */
   not "Denominator Exclusion"
   and not "Numerator Performance Met: G9308"
