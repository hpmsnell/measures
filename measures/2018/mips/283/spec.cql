library MIPS_283_2018 version '1'

/*
 * Source: MIPS
 * ID: 283
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 283 Encounter"
valueset "MIPS; Dementia"
valueset "MIPS; Performance Met: G9919"
valueset "MIPS; Performance Met: G9920"
valueset "MIPS; Performance Not Met: G9921"

// Able value sets

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 283 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Dementia"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G9919":
  /*
   * config_link_id: G9919
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9919"] P
    with "Denominator Encounter" E
      such that P.relaventPeriod starts on or 12 months or less before start of E.relevantPeriod

define "Numerator Performance Met: G9920":
  /*
   * config_link_id: G9920
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9920"] P
    with "Denominator Encounter" E
      such that P.relaventPeriod starts on or 12 months or less before start of E.relevantPeriod

define "Numerator Performance Not Met: G9921":
  /*
   * config_link_id: G9921
   */
  not "Numerator Performance Met: G9919"
  and not "Numerator Performance Met: G9920"
