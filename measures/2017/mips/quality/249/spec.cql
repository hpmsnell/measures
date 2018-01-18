library MIPS_249_2017 version '1'

/*
 * Source: MIPS
 * ID: 249
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 249 Procedure"
valueset "MIPS; Barrett's Esophagus"
valueset "MIPS; Specimen Site Other Than Esophagus"
valueset "MIPS; Performance Met: 3126F"
valueset "MIPS; Denominator Exception: 3126F-1P"
valueset "MIPS; Performance Not Met: 3126F-8P"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 249 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Barrett's Esophagus"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Specimen Site Other Than Esophagus"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: 3126F":
  /*
   * config_link_id: 3126F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3126F"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: 3126F-1P":
  /*
   * config_link_id: 3126F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3126F-1P"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: 3126F-8P":
  /*
   * config_link_id: 3126F-8P
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: 3126F"
  and not "Denominator Exception: 3126F-1P"
