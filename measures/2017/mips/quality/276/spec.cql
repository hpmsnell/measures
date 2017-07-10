library MIPS_276_2017 version '1'

/*
 * Source: MIPS
 * ID: 276
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 049 Encounter"
valueset "MIPS; Sleep Apnea"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Performance Met: G8839"
valueset "MIPS; Denominator Exception: G8840"
valueset "MIPS; Performance Not Met: G8841"

// Able value sets

valueset "Able; Sleep Apnea Assessment"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 276 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.code.modifier not in "MIPS; Telehealth Modifier"
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Sleep Apnea"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G8839":
  /*
   * config_link_id: G8839
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8839"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Assessment, Performed": "Able; Sleep Apnea Assessment"] P
    where P.authorDateTime during "Measurement Period")

define "Denominator Exception: G8840":
  /*
   * config_link_id: G8840
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8840"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G8841":
  /*
   * config_link_id: G8841
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G8839"
