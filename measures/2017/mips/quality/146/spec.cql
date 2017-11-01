library MIPS_146_2017 version '1'

/*
 * Source: MIPS
 * ID: 146
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 146 Procedure"
valueset "MIPS; Mammogram"
valueset "MIPS; Performance Met: 3343F"
valueset "MIPS; Performance Not Met: 3340F"
valueset "MIPS; Performance Not Met: 3341F"
valueset "MIPS; Performance Not Met: 3342F"
valueset "MIPS; Performance Not Met: 3344F"
valueset "MIPS; Performance Not Met: 3345F"
valueset "MIPS; Performance Not Met: 3350F"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 146 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Mammogram"] D
      such that D.relevantPeriod starts during E.relevantPeriod

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: 3343F":
  /*
   * config_link_id: 3343F
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: 3343F"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 3340F":
  /*
   * config_link_id: 3340F
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: 3340F"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 3341F":
  /*
   * config_link_id: 3341F
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: 3341F"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 3342F":
  /*
   * config_link_id: 3342F
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: 3342F"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 3344F":
  /*
   * config_link_id: 3344F
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: 3344F"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 3345F":
  /*
   * config_link_id: 3345F
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: 3345F"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 3350F":
  /*
   * config_link_id: 3350F
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: 3350F"] P
      such that P.relevantPeriod starts during E.relevantPeriod
