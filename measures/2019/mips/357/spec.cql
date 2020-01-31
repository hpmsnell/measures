library MIPS_357_2019 version '1'

/*
 * Source: MIPS
 * ID: 357
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 357 Procedure"
valueset "MIPS; Performance Met: G9312"
valueset "MIPS; Performance Not Met: G9311"

// Able Value Sets

valueset "Able; Surgical Site Infection"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Encounter Interval":
  Interval[start of "Measurement Period", end of "Measurement Period" - 1 month]

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 357 Procedure"] E
    where E.relevantPeriod starts during "Encounter Interval"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and not E.code.modifier in {'51', '80'}
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9312":
  /*
   * config_link_id: G9312
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9312"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 30 days or less after end of E.relevantPeriod)
  or exists(["Procedure, Performed" "Able; Surgical Site Infection"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 30 days or less after end of E.relevantPeriod)

define "Numerator Performance Not Met: G9311":
  /*
   * config_link_id: G9311
   */
  not "Numerator Performance Met: G9312"
