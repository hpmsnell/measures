library MIPS_076_2019 version '1'

/*
 * Source: MIPS
 * ID: 076
 * Year: 2019
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 076 Procedure"
valueset "MIPS; Performance Met: 6030F"
valueset "MIPS; Performance Met: 6030F-1P"
valueset "MIPS; Performance Not Met: 6030F-8P"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 076 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
    and not E.code.modifier in {'51', '80'}
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: 6030F":
  /*
   * config_link_id: 6030F
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: 6030F"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod

define "Denominator Exception: 6030F-1P":
  /*
   * config_link_id: 6030F-1P
   */
   "Denominator Procedure" E
     with ["Procedure, Performed": "MIPS; Denominator Exception: 6030F-1P"] P
       such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 6030F-8P":
  /*
   * config_link_id: 6030F-8P
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: 6030F-8P"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod

define "Numerator Performance Not Met: No Quality Data Code":
 /*
  * config_link_id: nodata
  */
  not "Numerator Performance Met: 6030F"
  and not "Denominator Exception: 6030F-1P"
  and not "Numerator Performance Not Met: 6030F-8P"
