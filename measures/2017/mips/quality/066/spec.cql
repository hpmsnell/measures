library MIPS_066_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 066
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 * Reviewed by: Rachel Katz 2017-05-23
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 066 Encounter"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Pharyngitis"
valueset "MIPS; Patient Prescribed Antibiotic"
valueset "MIPS; Existing Use of Antibioitic"
valueset "MIPS; Performance Met: 3210F"
valueset "MIPS; Performance Not Met: 3210F-8P"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Antibiotic Medications for Pharyngitis": '2.16.840.1.113883.3.464.1003.196.12.1001'
valueset "VSAC; Group A Streptococcus Test": '2.16.840.1.113883.3.464.1003.198.12.1012'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Antibiotic Prescription":
  ["Procedure, Performed": "MIPS; Patient Prescribed Antibiotic"]
  union ["Medication, Order": "VSAC; Antibiotic Medications for Pharyngitis"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 066 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 3
      and AgeInYearsAt(start of E.relevantPeriod) < 18
      and E.signingProvider.pqrsProvider = true
    with ["Diagnosis": "MIPS; Pharyngitis"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
    and with "Antibiotic Prescription" M
      such that M.relevantPeriod starts on or 3 days or less after start of E.relevantPeriod

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion 1":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Existing Use of Antibiotic"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts 30 days or less before start of E.relevantPeriod)
  or exists(["Medication": "VSAC; Antibiotic Medications for Pharyngitis"] M
    with "Denominator Encounter" E
      such that M.relevantPeriod starts 30 days or less before start of E.relevantPeriod)

define "Denominator Exclusion 2":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Met: 3210F":
  /*
   * config_link_id: 3210F
   */
  exists(["Procedure, Performed": "Performance Met: 3210F"] P
      with "Denominator Encounter" E
        such that P.relevantPeriod starts 3 days or less before start of E.relevantPeriod)
  or exists(["Procedure, Performed": "Performance Met: 3210F"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 3 days or less after start of E.relevantPeriod)
  or exists(["Laboratory Test, Performed": "VSAC; Group A Streptococcus Test"] L
    with "Denominator Encounter" E
      such that M.relevantPeriod starts on or 3 days or less after start of E.relevantPeriod)
  or exists(["Laboratory Test, Performed": "VSAC; Group A Streptococcus Test"] L
    with "Denominator Encounter" E
      such that M.relevantPeriod starts 3 days or less before start of E.relevantPeriod)

define "Numerator Performance Not Met: 3210F-8P":
  /*
   * config_link_id: 3210F-8P
   */
  not "Numerator Performance Met: 3210F"
