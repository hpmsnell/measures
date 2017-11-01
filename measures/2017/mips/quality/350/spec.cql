library MIPS_350_2017 version '1'

/*
 * Source: MIPS
 * ID: 350
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 350 Procedure"
valueset "MIPS; Performance Met: G9296"
valueset "MIPS; Performance Not Met: G9297"

// Able value Sets

valueset "Able; Shared Decision-Making"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 350 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9296":
  /*
   * config_link_id: G9296
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9296"] P
      such that P.relevantPeriod starts 30 days or less before start of E.relevantPeriod
  or "Denominator Procedure" E
    with ["Procedure, Performed": "Able; Shared Decision-Making"] P
      such that P.relevantPeriod starts 30 days or less before start of E.relevantPeriod

define "Numerator Performance Not Met: G9297":
  /*
   * config_link_id: G9297
   */
  not "Numerator Performance Met: G9296"
