library MIPS_065_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 065
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 * Reviewed by: Rachel Katz 2017-05-23
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 065 Encounter"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Upper Respiratory Infection"
valueset "MIPS; Medical Reason for Antibiotic"
valueset "MIPS; Existing Use of Antibioitic"
valueset "MIPS; Performance Met: G8708"
valueset "MIPS; Performance Not Met: G8710"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Competing Conditions for Respiratory Conditions": '2.16.840.1.113883.3.464.1003.102.12.1017'
valueset "VSAC; Antibiotic Medications for Pharyngitis": '2.16.840.1.113883.3.464.1003.196.12.1001'

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 065 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInMonthsAt(start of E.relevantPeriod) >= 3
      and AgeInYearsAt(start of E.relevantPeriod) < 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Upper Respiratory Infection"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion 1":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Medical Reason for Antibiotic"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 3 days or less after start of E.relevantPeriod)
  or exists(["Diagnosis": "VSAC; Competing Conditions for Respiratory Conditions"] D
    with "Denominator Encounter" E
      such that D.prevalencePeriod starts on or 3 days or less after start of E.relevantPeriod)

define "Denominator Exclusion 2":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Procedure, Performed": "MIPS; Existing Use of Antibiotic"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts 30 days or less before start of E.relevantPeriod)
  or exists(["Medication": "VSAC; Antibiotic Medications for Pharyngitis"] M
    with "Denominator Encounter" E
      such that M.relevantPeriod starts 30 days or less before start of E.relevantPeriod)

define "Denominator Exclusion 3":
  /*
   * config_link_id: exclusion_3
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Numerator Performance Met: G8708":
  /*
   * config_link_id: G8708
   */
  exists(["Procedure, Performed": "Performance Met: G8708"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 3 days or less after start of E.relevantPeriod)
  or not exists(["Medication, Order": "VSAC; Antibiotic Medications for Pharyngitis"] M
    where E.signingProvider.hasMeasureMembership = true
    with "Denominator Encounter" E
      such that M.relevantPeriod starts on or 3 days or less after start of E.relevantPeriod)

define "Numerator Performance Not Met: G8710":
  /*
   * config_link_id: G8710
   */
  not "Numerator Performance Met: G8708"
