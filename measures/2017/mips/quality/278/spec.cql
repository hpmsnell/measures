library MIPS_278_2017 version '1'

/*
 * Source: MIPS
 * ID: 278
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 278 Encounter"
valueset "MIPS; Sleep Apnea"
valueset "MIPS; Moderate or Severe Obstructive Sleep Apnea"
valueset "MIPS; Performance Met: G8845"
valueset "MIPS; Denominator Exception: G8849"
valueset "MIPS; Performance Not Met: G8850"

// Able value sets

valueset "Able; Positive Airway Pressure Therapy"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 278 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.code.modifier not in {'GQ', 'GT'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Sleep Apnea"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod
    with ["Procedure, Performed": "MIPS; Moderate or Severe Obstructive Sleep Apnea"] P
      such that P.relevantPeriod starts during D.prevalencePeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G8845":
  /*
   * config_link_id: G8845
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8845"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Assessment, Performed": "Able; Positive Airway Pressure Therapy"] P
    where P.authorDateTime during "Measurement Period")

define "Denominator Exception: G8849":
  /*
   * config_link_id: G8849
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8849"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G8850":
  /*
   * config_link_id: G8850
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G8845"
