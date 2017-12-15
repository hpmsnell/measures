library MIPS_104_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 104
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 * Reviewed by: Rachel Katz 2017-07-18
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 104 Encounter"
valueset "MIPS; Prostate Cancer"
valueset "MIPS; High Risk of Recurrence of Prostate Cancer"
valueset "MIPS; Metastatic Cancer"
valueset "MIPS; Performance Met: 4164F"
valueset "MIPS; Denominator Exception: 4164F-1P"
valueset "MIPS; Denominator Exception: 4164F-2P"
valueset "MIPS; Performance Not Met: 4164F-8P"

// VSAC value sets

valueset "VSAC; Salvage Therapy": '2.16.840.1.113883.3.526.3.399'

// Able value sets

valueset "Able; GnRH"
valueset "Able; GnRH Administered"
valueset "Able; High Risk of Recurrence of Prostate Cancer"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 104 Encounter"] E1
    where E1.relevantPeriod starts during "Denominator Period"
      and "Patient Characteristic Sex" = "Male"
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Prostate Cancer"] D
      such that D.prevalencePeriod overlaps E1.relevantPeriod
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
    where P.relevantPeriod starts during [56 days before start of "Denominator Period", end of "Denominator Period"])

define "Denominator Exclusion"
  /*
   * config_link_id: exclusion
   */
  exists(["Diagnosis": "MIPS; Metastatic Cancer"] D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Met: 4164F":
  /*
   * config_link_id: 4164F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4164F"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 56 days or less after start of E.relevantPeriod)
 or exists(["Procedure, Performed": "Able; GnRH Administered"] P
   with "Denominator Encounter" E
     such that P.relevantPeriod starts on or 56 days or less after start of E.relevantPeriod)
  or exists(["Medication": "Able; GnRH"] M
    with "Denominator Encounter" E
      such that M.relevantPeriod overlaps [start of E.relevantPeriod, start of E.relevantPeriod + 56 days)

define "Denominator Exception: 4164F-1P":
  /*
   * config_link_id: 4164F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4164F-1P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 56 days or less after start of E.relevantPeriod)
  or exists("VSAC; Salvage Therapy" P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 56 days or less after start of E.relevantPeriod)

define "Denominator Exception: 4164F-2P":
  /*
   * config_link_id: 4164F-2P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4164F-2P"] P
    with "Denominator Encounter" E
          such that P.relevantPeriod starts on or 56 days or less after start of E.relevantPeriod)

define "Numerator Performance Not Met: 4164F-8P":
  /*
   * config_link_id: 4164F-8P
   */
  not "Numerator Performance Met: 4164F"
  and not "Denominator Exception: 4164F-1P"
  and not "Denominator Exception: 4164F-2P"
