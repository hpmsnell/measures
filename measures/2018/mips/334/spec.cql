library MIPS_334_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 334
 * Year: 2018
 * Version: 2
 * Written by: Becky
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 334 Encounter"
valueset "MIPS; Chronic Sinusitis"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Performance Met: G9352"
valueset "MIPS; Denominator Exception: G9353"
valueset "MIPS; Performance Not Met: G9354"

// Able value sets

valueset "Able; CT Scan of Paranasal Sinuses"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Chronic Sinusitis Interval":
  Interval[Start of "Measurement Period", 90 days before end "Measurement Period"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 334 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"
    with ["Diagnosis": "MIPS; Chronic Sinusitis"] D
      such that D.prevalencePeriod starts during "Chronic Sinusitis Interval"

define "Performance Met Exists":
  exists(["Procedure, Performed": "MIPS; Performance Met: G9352"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 90 days or less after start of E.relevantPeriod)
  or count(["Procedure, Performed": "Able; CT Scan of Paranasal Sinuses"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 90 days or less after start of E.relevantPeriod) > 1

define "Denominator Exception Exists":
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9353"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 90 days or less after start of E.relevantPeriod)

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G9352":
  /*
   * config_link_id: G9352
   */
  "Performance Met Exists"
  and not "Denominator Exception Exists"

define "Denominator Exception: G9353":
  /*
   * config_link_id: G9353
   */
  "Performance Met Exists"
  and "Denominator Exception Exists"

define "Numerator Performance Not Met: G9354":
  /*
   * config_link_id: G9354
   */
  not "Numerator Performance Met: G9352"
  anf not "Denominator Exception: G9353"
