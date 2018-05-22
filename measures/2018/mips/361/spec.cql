library MIPS_361_2017 version '1'

/*
 * Source: MIPS
 * ID: 361
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 361 Procedure"
valueset "MIPS; Performance Met: G9327"
valueset "MIPS; Performance Not Met: G9326"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 361 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9327":
  /*
   * config_link_id: G9327
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9327"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod

define "Numerator Performance Not Met: G9326":
  /*
   * config_link_id: G9326
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: G9326"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod

define "Numerator Performance Not Met: No Quality Data Code":
  /*
   * config_link_id: no_qdc
   */
  not "Numerator Performance Met: G9327"
    and not "Numerator Performance Not Met: G9326"
