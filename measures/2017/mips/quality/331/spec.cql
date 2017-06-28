library MIPS_331_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 331
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 * Reviewed by: Rachel Katz 2017-05-23
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 331 Encounter"
valueset "MIPS; Acute Sinusitis"
valueset "MIPS; Performance Met: G9286"
valueset "MIPS; Denominator Exception: G9505"
valueset "MIPS; Performance Not Met: G9287"

// VSAC value sets

valueset "VSAC; Competing Conditions for Respiratory Conditions": '2.16.840.1.113883.3.464.1003.102.12.1017'

// Able value sets

valueset "Able; Systemic Antibiotics"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 331 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"
    with ["Diagnosis": "MIPS; Acute Sinusitis"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Performance Met Exists":
  exists(["Procedure, Performed": "Performance Met: G9286"] P
    with "Denominator Encounter" E
      such that M.relevantPeriod starts on or 10 days or less after start of E.relevantPeriod)
  or exists(["Medication, Order": "Able; Systemic Antibiotics"] M
    with "Denominator Encounter" E
      such that M.relevantPeriod starts on or 10 days or less after start of E.relevantPeriod)

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G9286":
  /*
   * config_link_id: G9286
   */
  "Performance Met Exists"
  and not "Denominator Exception: G9505"

define "Denominator Exception: G9505":
  /*
   * config_link_id: G9505
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9505"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 10 days or less after start of E.relevantPeriod)
  or exists(["Diagnosis": "VSAC; Competing Conditions for Respiratory Conditions"] D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps Interval[start of E.relevantPeriod, E.relevantPeriod + 10 days])

define "Numerator Performance Not Met: G9287":
  /*
   * config_link_id: G9287
   */
  not "Numerator Performance Met: G9286"
  anf not "Denominator Exception: G9505"
