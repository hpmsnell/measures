library MIPS_023_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 023
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 * Reviewed by: Rachel Katz 2017-05-23
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 023 Procedure"
valueset "MIPS; Performance Met: 4044F"
valueset "MIPS; Denominator Exception: 4044F-1P"
valueset "MIPS; Performance Not Met: 4044F-8P"

// Able value sets

valueset "Able; VTE Prophylaxis"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 023 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: 4044F":
  /*
   * config_link_id: 4044F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4044F"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 14 days or less before start of E.relevantPeriod)
  or exists(["Medication, Order": "Able; VTE Prophylaxis"] M
    with "Denominator Procedure" E
      such that M.relevantPeriod starts 14 days or less before start of E.relevantPeriod)

define "Denominator Exception: 4044F-1P":
  /*
   * config_link_id: 4044F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4044F-1P"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 14 days or less before start of E.relevantPeriod)

define "Numerator Performance Not Met: 4044F-8P":
  /*
   * config_link_id: 4044F-8P
   */
  not "Numerator Performance Met: 4044F"
  anf not "Denominator Exception: 4044F-1P"
