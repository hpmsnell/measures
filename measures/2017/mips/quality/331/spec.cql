library MIPS_331_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 331
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 * Reviewed by: Rachel Katz 2017-07-18
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 331 Encounter"
valueset "MIPS; Acute Sinusitis"
valueset "MIPS; Performance Met: G9286"
valueset "MIPS; Denominator Exception: G9505"
valueset "MIPS; Performance Not Met: G9287"

// Able value sets

valueset "Able; Systemic Antibiotics"
valueset "Able; Competing Conditions for Sinusitis"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 331 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS; Acute Sinusitis"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Performance Met Exists":
  exists(["Procedure, Performed": "Performance Met: G9286"] P
    with "Denominator Encounter" E
      such that M.relevantPeriod starts on or 10 days or less after start of E.relevantPeriod)
  or exists(["Medication, Order": "Able; Systemic Antibiotics"] M
    where E.signingProvider.hasMeasureMembership = true
    with "Denominator Encounter" E
      such that M.relevantPeriod starts on or 10 days or less after start of E.relevantPeriod)

define "Denominator Exception Exists":
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9505"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 10 days or less after start of E.relevantPeriod)
  or exists(["Diagnosis": "Able; Competing Conditions for Sinusitis"] D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps Interval[start of E.relevantPeriod, E.relevantPeriod + 10 days])

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G9286":
  /*
   * config_link_id: G9286
   */
  "Performance Met Exists"
  and not "Denominator Exception Exists"
  and not exists(
    exists(["Procedure, Performed": "Performance Not Met: G9287"] P
      with "Denominator Encounter" E
        such that M.relevantPeriod starts on or 10 days or less after start of E.relevantPeriod)

define "Denominator Exception: G9505":
  /*
   * config_link_id: G9505
   */
  "Performance Met Exists"
  and "Denominator Exception Exists"

define "Numerator Performance Not Met: G9287":
  /*
   * config_link_id: G9287
   */
  not "Numerator Performance Met: G9286"
  anf not "Denominator Exception: G9505"
