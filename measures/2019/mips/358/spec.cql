library MIPS_358_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 358
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 358 Encounter"
valueset "MIPS; Emergency Surgery"
valueset "MIPS; Performance Met: G9316"
valueset "MIPS; Performance Not Met: G9317"


parameter "Measurement Period" Interval<DateTime>

context Patient


define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 358 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and not E.code.modifier in {'51', '80'}
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion"
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Emergency Surgery"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G9316":
  /*
   * config_link_id: G9316
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9316"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 30 days or less before E.relevantPeriod)

define "Numerator Performance Not Met: G9317":
  /*
   * config_link_id: G9317
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G9316"
