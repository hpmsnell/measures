library MIPS_116_2020 version '1'

/*
 *
 * Source: MIPS
 * ID: 116
 * Year: 2020
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 116 Encounter"
valueset "MIPS; Acute Bronchitis"
valueset "MIPS; Denominator Exclusion: G9712"
valueset "MIPS; Performance Met: 4124F"
valueset "MIPS; Performance Not Met: 4120F"
valueset "MIPS; Hospice Service"

// HEDIS value sets

valueset "HEDIS; Inpatient Stay"
valueset "HEDIS; HIV"
valueset "HEDIS; HIV Type 2"
valueset "HEDIS; Malignant Neoplasms"
valueset "HEDIS; Emphysema"
valueset "HEDIS; COPD"
valueset "HEDIS; Cystic Fibrosis"
valueset "HEDIS; Comorbid Conditions"
valueset "HEDIS; Disorders of the Immune System"
valueset "HEDIS; Other Malignant Neoplasm of Skin"
valueset "HEDIS; Pharyngitis"
valueset "HEDIS; Competing Diagnosis"

// VSAC value sets

valueset "VSAC; Palliative Care"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 116 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and AgeInYearsAt(start of E.relevantPeriod) < 64
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Acute Bronchitis"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Excluded Diagnosis":
  ["Diagnosis": "HEDIS; HIV"]
  union ["Diagnosis": "HEDIS; HIV Type 2"]
  union ["Diagnosis": "HEDIS; Malignant Neoplasms"]
  union ["Diagnosis": "HEDIS; Emphysema"]
  union ["Diagnosis": "HEDIS; COPD"]
  union ["Diagnosis": "HEDIS; Cystic Fibrosis"]
  union ["Diagnosis": "HEDIS; Comorbid Conditions"]
  union ["Diagnosis": "HEDIS; Disorders of the Immune System"]
  union ["Diagnosis": "HEDIS; Other Malignant Neoplasm of Skin"]
  union ["Diagnosis": "HEDIS; Pharyngitis"]
  union ["Diagnosis": "HEDIS; Competing Diagnosis"]

define "Hospice Service":
  ["Procedure, Performed": "MIPS; Hospice Service"]
  union ["Procedure, Performed": "VSAC; Palliative Care"]

// Populations

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion: Inpatient Stay":
  /*
   * config_link_id: exclusion_1
   */
  exists("Denominator Encounter" E1
    with ["Encounter, Performed": "HEDIS; Inpatient Stay"] E2
      such that E2.relevantPeriod starts on or 1 days or less after start of E1.relevantPeriod)


define "Denominator Exclusion: Competing Condition":
  /*
   * config_link_id: exclusion_2
   */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exclusion: G9712"] P
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Denominator Encounter" E
    with "Competing Diagnosis" D
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Denominator Exclusion: Hospice Service":
  /*
   * config_link_id: exclusion_3
   */
  exists("Hospice Service" P
      such that P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 4124F":
  /*
   * config_link_id: 4124F
   */
  not exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: 4120F"] P
      such that P.relevantPeriod starts on or 3 days or less after E.relevantPeriod)

define "Numerator Performance Not Met: 4120F":
  /*
   * config_link_id: 4120F
   */
  not "Denominator Exclusion: Inpatient Stay"
  and not "Denominator Exclusion: Competing Condition"
  and not "Denominator Exclusion: Hospice Service"
  and not "Numerator Performance Met: 4124F"
