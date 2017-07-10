library MIPS_333_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 333
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 333 Encounter"
valueset "MIPS; Acute Sinusitis"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Performance Met: G9349"
valueset "MIPS; Denominator Exception: G9348"
valueset "MIPS; Performance Not Met: G9350"

// VSAC value sets

valueset "VSAC; Immunodeficient Conditions": '2.16.840.1.113883.3.666.5.1726'

// Able value sets

valueset "Able; CT Scan of Paranasal Sinuses"
valueset "Able; Chronic Sinusitis"
valueset "Able; Acute Frontal or Sphenoid Sinusitis"
valueset "Able; Periorbital Cellulitis"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 333 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"
    with ["Diagnosis": "MIPS; Acute Sinusitis"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Performance Met":
  ["Procedure, Performed": "MIPS; Performance Met: G9349"]
  union ["Procedure, Performed": "Able; CT Scan of Paranasal Sinuses"]

define "Performance Met Exists":
  exists("Performance Met" P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 28 days or less after start of E.relevantPeriod)

define "Excepted Conditions":
  ["Diagnosis": "VSAC; Immunodeficient Conditions"]
  union ["Diagnosis": "Able; Chronic Sinusitis"]
  union ["Diagnosis": "Able; Acute Frontal or Sphenoid Sinusitis"]
  union ["Diagnosis": "Able; Periorbital Cellulitis"]

define "Denominator Exception Exists":
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9348"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 28 days or less after start of E.relevantPeriod)
  or exists("Excepted Conditions" D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps Interval[start of E.relevantPeriod, E.relevantPeriod + 28 days])

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G9349":
  /*
   * config_link_id: G9349
   */
  "Performance Met Exists"
  and not "Denominator Exception Exists"

define "Denominator Exception: G9348":
  /*
   * config_link_id: G9348
   */
  "Performance Met Exists"
  and "Denominator Exception Exists"

define "Numerator Performance Not Met: G9350":
  /*
   * config_link_id: G9350
   */
  not "Numerator Performance Met: G9349"
  anf not "Denominator Exception: G9348"
