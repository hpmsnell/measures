library MIPS_104_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 104
 * Year: 2018
 * Version: 1
 * Written by: Becky Weber
 * Reviewed by: Steve Daniels 2018-05-01
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 104 Encounter"
valueset "MIPS; Prostate Cancer"
valueset "MIPS; High Risk of Recurrence of Prostate Cancer"
valueset "MIPS; Metastatic Cancer"
valueset "MIPS; Performance Met: G9894"
valueset "MIPS; Denominator Exception: G9895"
valueset "MIPS; Denominator Exception: G9896"
valueset "MIPS; Performance Not Met: G9897"

// VSAC value sets

valueset "VSAC; Salvage Therapy": '2.16.840.1.113883.3.526.3.399'

// Able value sets

valueset "Able; GnRH"
valueset "Able; GnRH Administered"
valueset "Able; High Risk of Recurrence of Prostate Cancer"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 104 Encounter"] E1
    where E1.relevantPeriod starts during "Measurement Period"
      and "Patient Characteristic Sex" = "Male"
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Prostate Cancer"] D
      such that D.prevalencePeriod starts on or 56 days or less before start of E1.relevantPeriod
    without ["Encounter, Performed": "MIPS; MIPS 104 Encounter"] E2 // Without an additional occurrence of the same encounter
      such that E2.relevantPeriod starts 56 days or less before start of E1.relevantPeriod

define "High Risk of Recurrence of Prostate Cancer":
  ["Procedure, Performed": "MIPS; High Risk of Recurrence of Prostate Cancer"]
  union ["Procedure, Performed": "Able; High Risk of Recurrence of Prostate Cancer"]

define "Start of Denominator Encounter":
  "Denominator Encounter" E
    return start of E.relevantPeriod

define "Date of Earliest Diagnosis in Measurement Year":
  First(["Diagnosis": "MIPS; Prostate Cancer"] D
    where D.prevalencePeriod starts during "Measurement Year"
    return start of D.prevalencePeriod)

define "Denominator":
  "Denominator Encounter"
  and exists("High Risk of Recurrence of Prostate Cancer" P
    where P.relevantPeriod starts during [56 days before start of "Measurement Period", end of "Measurement Period"])

define "Denominator Exclusion"
  /*
   * config_link_id: exclusion
   */
  exists(["Diagnosis": "MIPS; Metastatic Cancer"] D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Met: G9894":
  /*
   * config_link_id: G9894
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9894"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 56 days or less after start of E.relevantPeriod)
 or exists(["Procedure, Performed": "Able; GnRH Administered"] P
   with "Denominator Encounter" E
     such that P.relevantPeriod starts on or 56 days or less after start of E.relevantPeriod)
  or exists(["Medication": "Able; GnRH"] M
    with "Denominator Encounter" E
      such that M.relevantPeriod overlaps [start of E.relevantPeriod, start of E.relevantPeriod + 56 days)

define "Denominator Exception: G9895":
  /*
   * config_link_id: G9895
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9895"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
  or exists("VSAC; Salvage Therapy" P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception: G9896":
  /*
   * config_link_id: G9896
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9896"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G9897":
  /*
   * config_link_id: G9897
   */
  not "Numerator Performance Met: G9894"
  and not "Denominator Exception: G9895"
  and not "Denominator Exception: G9896"
