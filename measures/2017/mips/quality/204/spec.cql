library MIPS_204_2017 version '1'

/*
 * Source: MIPS
 * ID: 204
 * Year: 2017
 * Version: 1
 */

using QDM

// Able value sets

valueset "Able; Aspirin and Clopidogrel"

// MIPS value sets

valueset "MIPS; MIPS 204 Encounter"
valueset "MIPS; Ischemic Vascular Disease"
valueset "MIPS; Acute Myocardial Infarction"
valueset "MIPS; Coronary Intervention"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Anticoagulant"
valueset "MIPS; Performance Met: G8598"
valueset "MIPS; Performance Not Met: G8599"


// VSAC value sets

valueset "VSAC; Anticoagulant Medications": '	2.16.840.1.113883.3.464.1003.196.11.1283'

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 204 Encounter"] E
      where E.relevantPeriod starts during "Denominator Period"
        and AgeInYearsAt(start of E.relevantPeriod) >= 18
        and not E.code.modifier "MIPS; Telemedicine Modifier"
        and E.signingProvider.hasMeasureMembership = true

define "Denominator Diagnosis":
  ["Diagnosis": "MIPS; Ischemic Vascular Disease"]
  union ["Diagnosis": "MIPS; Acute Myocardial Infarction"]

define "Denominator Procedure":
  ["Procedure, Performed": "Coronary Intervention"]

define "Procedure or Diagnosis Exists":
  exists("Denominator Diagnosis" D
    where D.prevalencePeriod overlaps "Denominator Period")
  or exists("Denominator Procedure" P
    where P.relevantPeriod starts during "Denominator Period")

define "Denominator":
  exists("Denominator Encounter")
  and "Procedure or Diagnosis Exists"

define "Denominator Exclusion 1":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Denominator Exclusion 2":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Medication": "VSAC; Anticoagulant"] M
    where M.relevantPeriod starts during "Denominator Period")

define "Numerator Performance Met: G8598":
  /*
   * config_link_id: G8598
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8598"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists (["Medication": "Able; Aspirin and Clopidogrel"] M
    where M.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Not Met: G8599":
  /*
   * config_link_id: G8599
   */
  not "Numerator Performance Met: G8598"
