library MIPS_102_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 102
 * Year: 2018
 * Version: 1
 * Written by: Becky Weber
 * Reviewed by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 102 Encounter"
valueset "MIPS; Prostate Cancer"
valueset "MIPS; Low Risk of Recurrence of Prostate Cancer"
valueset "MIPS; Performance Met: 3270F"
valueset "MIPS; Denominator Exception: 3269F-1P"
valueset "MIPS; Denominator Exception: 3269F-3P"
valueset "MIPS; Performance Not Met: 3269F"

// VSAC value sets

valueset "VSAC; Bone Scan": '2.16.840.1.113883.3.526.3.320'
valueset "VSAC; Standardized Pain Assessment Tool": '2.16.840.1.113883.3.526.3.1028'
valueset "VSAC; Salvage Therapy": '2.16.840.1.113883.3.526.3.399'

// Able value sets

valueset "Able; Bone Health Assessment": '2.16.840.1.113762.1.4.1047.234'
valueset "Able; Pain Assessments": '2.16.840.1.113762.1.4.1047.152'
valueset "Able; Gleason Score Below 7"
valueset "Able; PSA Serum Test"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 102 Encounter"] E1
    where E1.relevantPeriod starts during "Measurement Period"
      and "Patient Characteristic Sex" = 'Male'
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Prostate Cancer"] D
      such that D.prevalencePeriod starts on or 56 days or less before start of E1.relevantPeriod
    without ["Encounter, Performed": "MIPS; MIPS 102 Encounter"] E2 // Without an additional occurrence of the same encounter
      such that E2.relevantPeriod starts 56 days or less before start of E1.relevantPeriod

define "PSA Serum Test < 10":
  ["Laboratory Test, Performed": "Able; PSA Serum Test"] L
    where L.resultDateTime during "Measurement Period"
    where L.result < 10

define "Low Risk of Recurrence of Prostate Cancer":
  ["Procedure, Performed": "MIPS; Low Risk of Recurrence of Prostate Cancer"]
  union ["Procedure, Performed": "Able; Gleason Score Below 7"]
  union "PSA Serum Test < 10"

define "Start of Denominator Encounter":
  "Denominator Encounter" E
    return start of E.relevantPeriod

define "Date of Earliest Diagnosis in Measurement Year":
  First(["Diagnosis": "MIPS; Prostate Cancer"] D
    where D.prevalencePeriod starts during "Measurement Year"
    return start of D.prevalencePeriod)

define "Bone Scan Interval":
  Interval ["Date of Earliest Diagnosis in Measurement Year", "Start of Denominator Encounter" + 56 days]

define "Pain Assessment":
  ["Assessment, Performed": "VSAC; Standardized Pain Assessment Tool"]
  union ["Assessment, Performed": "VSAC; Pain Assessments"]

define "Bone Scan":
  ["Diagnostic Study, Performed": "VSAC; Bone Scan"]
  union ["Diagnostic Study, Performed": "VSAC; Bone Health Assessment Grouping"]

define "Denominator":
  "Denominator Encounter"
  and exists("Low Risk of Recurrence of Prostate Cancer" P
    where P.relevantPeriod starts during [56 days before start of "Measurement Period", end of "Measurement Period"])

define "Numerator Performance Met: 3270F":
  /*
   * config_link_id: 3270F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3270F"] P
    where P.relevantPeriod starts during "Bone Scan Interval")
  or not exists("Bone Scan" S
    where S.authorDateTime during "Bone Scan Interval")

define "Denominator Exception: 3269F-1P":
  /*
   * config_link_id: 3269F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3269F-1P"] P
    where P.relevantPeriod starts during "Bone Scan Interval")
  or exists("Pain Assessment" P
    where P.result > 0
      and P.relevantPeriod starts during "Bone Scan Interval")
  or exists("VSAC; Salvage Therapy" P
    where P.relevantPeriod starts during "Bone Scan Interval")

define "Denominator Exception: 3269F-3P":
  /*
   * config_link_id: 3269F-3P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3269-3P"] P
    where P.relevantPeriod starts during "Bone Scan Interval")

define "Numerator Performance Not Met: 3269F":
  /*
   * config_link_id: 3269F
   */
  not "Numerator Performance Met: 3270F"
  and not "Denominator Exception: 3269F-1P"
  and not "Denominator Exception: 3269F-2P"
