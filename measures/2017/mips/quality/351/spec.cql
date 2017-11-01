library MIPS_351_2017 version '1'

/*
 * Source: MIPS
 * ID: 351
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 351 Procedure"
valueset "MIPS; Performance Met: G9298"
valueset "MIPS; Performance Not Met: G9299"

// Able value Sets

valueset "Able; Cardiovascular Risk Assessment"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 351 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9298":
  /*
   * config_link_id: G9298
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9298"] P
      such that P.relevantPeriod starts 30 days or less before start of E.relevantPeriod
  or "Denominator Procedure" E
    with ["Procedure, Performed": "Able; Cardiovascular Risk Assessment"] P
      such that P.relevantPeriod starts 30 days or less before start of E.relevantPeriod

define "Numerator Performance Not Met: G9299":
  /*
   * config_link_id: G9299
   */
  not "Numerator Performance Met: G9298"
