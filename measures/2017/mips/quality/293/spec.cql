library MIPS_293_2017 version '1'

/*
 * Source: MIPS
 * ID: 293
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 293 Encounter"
valueset "MIPS; Parkinson's Disease"
valueset "MIPS; Performance Met: 4400F"
valueset "MIPS; Denominator Exception: 4400F-1P"
valueset "MIPS; Performance Not Met: 4400F-8P"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 293 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of P.relevantPeriod) >= 18
      and not E.code.modifier in {'GQ', 'GT'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Parkinson's Disease"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 4400F":
  /*
   * config_link_id: 4400F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4400F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 4400F-1P":
  /*
   * config_link_id: 4400F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4400F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 4400F-8P":
  /*
   * config_link_id: 4400F-8P
   */
  not "Numerator Performance Met: 4400F"
  and not "Denominator Exception: 4400F-1P"
