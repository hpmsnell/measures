library MIPS_225_2017 version '1'

/*
 * Source: MIPS
 * ID: 225
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 225 Procedure"
valueset "MIPS; Mammogram"
valueset "MIPS; Performance Met: 7025F"
valueset "MIPS; Denominator Exception: 7025F-1P"
valueset "MIPS; Performance Not Met: 7025F-8P"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 225 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Mammogram"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: 7025F":
  /*
   * config_link_id: 7025F
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: 7025F"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: 7025F-1P":
  /*
   * config_link_id: 7025F-1P
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Denomiantor Exception: 7025F-1P"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 7025F-8P":
  /*
   * config_link_id: 7025F-8P
   */
  not "Numerator Performance Met: 7025F"
  and not "Denominator Exception: 7025F-1P"
