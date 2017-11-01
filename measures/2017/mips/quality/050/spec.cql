library MIPS_050_2017 version '1'

/*
 * Source: MIPS
 * ID: 050
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Custom Value Sets

valueset "MIPS; MIPS 050 Encounter"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 0509F"
valueset "MIPS; Performance Not Met: 0509F-8P"
valueset "MIPS; Urinary Incontinence"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Female": '2.16.840.1.113883.3.560.100.2'
valueset "VSAC; Urological Surgery": '2.16.840.1.113883.17.4077.3.2061'

// Able Value Sets

valueset "Able; Urinary Incontinence Intervention"
valueset "Able; Urinary Incontinence Medication"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 050 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 65
      and "Patient Characteristic Sex" in "VSAC; Female"
      and E.signingProvider.hasMeasureMembership = true

define "Urinary Incontinence Intervention":
  ["Intervention, Performed": "Able; Urinary Incontinence Intervention"]
  union ["Procedure, Performed": "VSAC; Urological Surgery"]

define "Denominator":
  exists("Denominator Encounter")
  and exists(["Diagnosis": "MIPS; Urinary Incontinence" D
    where D.prevalencePeriod overlaps "Denominator Period")

define "Denominator Exclusion":
  /*
   * config_link_id: denominator_exclusion
   */
  exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")
  or exists("Urinary Incontinence Intervention" I
    where I.relevantPeriod starts during "Denominator Period")

define "Numerator Performance Met: 0509F":
  /*
   * config_link_id: 0509F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 0509F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Assessment, Performed": "Able; Urinary Incontinence Intervention"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Medication, Order": "Able; Urinary Incontinence Medication"] M
    where M.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Not Met: 0509F-8P":
  /*
   * config_link_id: 0509F-8P
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: 0509F"
