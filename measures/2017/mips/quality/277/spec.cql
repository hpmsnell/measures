library MIPS_277_2017 version '1'

/*
 * Source: MIPS
 * ID: 277
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 277 Encounter"
valueset "MIPS; Sleep Apnea"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Performance Met: G8842"
valueset "MIPS; Denominator Exception: G8843"
valueset "MIPS; Performance Not Met: G8844"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 277 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.code.modifier not in {'GQ', 'GT'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Sleep Apnea"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "First Sleep Apnea Diagnosis":
  First(["Diagnosis": "MIPS; Sleep Apnea"])

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G8842":
  /*
   * config_link_id: G8842
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8842"] P
    with "First Sleep Apnea Diagnosis" D
      such that P.relevantPeriod starts at start of D.prevalencePeriod)

define "Denominator Exception: G8843":
  /*
   * config_link_id: G8843
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8843"] P
    with "First Sleep Apnea Diagnosis" D
      such that P.relevantPeriod starts at start of D.prevalencePeriod)

define "Numerator Performance Not Met: G8844":
  /*
   * config_link_id: G8844
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G8842"
