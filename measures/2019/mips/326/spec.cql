library MIPS_326_2018 version '1'

/*
 * Source: MIPS
 * ID: 326
 * Year: 2018
 * Version: 1
 */

using QDM

// Able value sets

valueset "Able; Aspirin and Clopidogrel"

// MIPS value sets

valueset "MIPS; MIPS 326 Encounter"
valueset "MIPS; Nonvalvular Atrial Fibrillation or Atrial Flutter"
valueset "MIPS; Risk Factors for Thromboembolism"
valueset "MIPS; Denominator Exclusion: G9929"
valueset "MIPS; Denominator Exclusion: G9930"
valueset "MIPS; Denominator Exclusion: G9931"
valueset "MIPS; Performance Met: G8967"
valueset "MIPS; Denominator Exception: G8968"
valueset "MIPS; Denominator Exception: G8969"
valueset "MIPS; Denominator Exception: G9927"
valueset "MIPS; Performance Not Met: G9928"

// VSAC value sets

valueset "VSAC; Anticoagulant Medications": '	2.16.840.1.113883.3.464.1003.196.11.1283'
valueset "VSAC; Cerebrovascular disease, Stroke, TIA": '2.16.840.1.113762.1.4.1047.44'
valueset "VSAC; Heart Failure": '2.16.840.1.113883.3.526.3.376'
valueset "VSAC; Myocardial Infarction": '2.16.840.1.113883.3.526.3.403'
valueset "VSAC; Atherosclerosis and Peripheral Arterial Disease": '2.16.840.1.113762.1.4.1047.21'
valueset "VSAC; Diagnosis of hypertension": '2.16.840.1.113883.3.600.263'
valueset "VSAC; Diabetes": '2.16.840.1.113883.3.464.1003.103.12.1001'
valueset "VSAC; Anticoagulant ingredient specific": '2.16.840.1.113762.1.4.1021.9'

// Able value sets

valueset "Able; Mitral Stenosis"
valueset "Able; Prosthetic Heart Valve"
valueset "Able; Anticoagulant Allergy"
valueset "Able; Iron Deficiency Anemia"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 326 Encounter"] E
      where E.relevantPeriod starts during [start of "Measurement Period", 3 months before end of "Measurement Period"]
        and AgeInYearsAt(start of E.relevantPeriod) >= 18
        and not E.code.modifier in {'GQ','GT','95'}
        and not E.placeOfService in {'02'}
        and E.signingProvider.hasMeasureMembership = true
      with ["Diagnosis": "MIPS; Nonvalvular Atrial Fibrillation or Atrial Flutter"] D
        such that D.prevalencePeriod overlaps E.relevantPeriod

define "Patient 75":
  exists("Denominator Encounter" E
    where AgeInYearsAt(start of E.relevantPeriod) >= 75)

define "Stroke Exists":
  exists(["Diagnosis": "VSAC; Cerebrovascular disease, Stroke, TIA"] D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "CHF Exists":
  exists(["Diagnosis": "VSAC; Heart Failure"] D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Hypertension Exists":
  exists(["Diagnosis": "VSAC; Diagnosis of hypertension"] D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Diabetes Exists":
  exists(["Diagnosis": "VSAC; Diabetes"] D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Vascular Disease":
  ["Diagnosis": "VSAC; Myocardial Infarction"]
  union ["Diagnosis": "VSAC; Atherosclerosis and Peripheral Arterial Disease"]

define "Vascular Disease Exists":
  exists("Vascular Disease" D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Patient 64":
  exists("Denominator Encounter" E
    where AgeInYearsAt(start of E.relevantPeriod) >= 64)

define "Patient Female":
  PatientCharacteristicSex = "Female"

define "CHADS-VASc >= 2"
  "Patient 75"
  or "Stroke Exists"
  or (
    "CHF Exists"
    and (
      "Hypertension Exists"
      or "Diabetes Exists"
      or "Vascular Disease Exists"
      or "Patient 64"
      or "Patient Female"
    )
  )
  or (
    "Hypertension Exists"
    and (
      "Diabetes Exists"
      or "Vascular Disease Exists"
      or "Patient 64"
      or "Patient Female"
    )
  )
  or (
    "Diabetes Exists"
    and (
      "Vascular Disease Exists"
      or "Patient 64"
      or "Patient Female"
    )
  )
  or (
    "Vascular Disease Exists"
    and (
      "Patient 64"
      or "Patient Female"
    )
  )
  or (
    "Patient 64"
    and "Patient Female"
  )

/* Populations */

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion 1":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Assessment, Performed": "MIPS; Denominator Exclusion: G9929"] A
    where A.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion 2":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Assessment, Performed": "MIPS; Denominator Exclusion: G9930"] A
    where A.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion 3":
  /*
   * config_link_id: exclusion_3
   */
  exists(["Assessment, Performed": "MIPS; Denominator Exclusion: G9931"] A
    where A.relevantPeriod starts during "Measurement Period")
  or not "CHADS-VASc >= 2"

define "Numerator Performance Met: G8967":
  /*
   * config_link_id: G8967
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8967"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists (["Medication": "VSAC; Anticoagulant Medication"] M
    where M.relevantPeriod overlaps "Measurement Period")

define "Denominator Exception: G8968":
  /*
   * config_link_id: G8968
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8968"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists (["Allergy": "VSAC; Anticoagulant ingredient specific"] A
    with "Denominator Encounter" E
      such that A.prevalencePeriod overlaps E.relevantPeriod)
  or exists (["Diagnosis": "Able; Anticoagulant Allergy"] D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)
  or exists (["Diagnosis": "Able; Iron Deficiency Anemia"] D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Denominator Exception: G8969":
  /*
   * config_link_id: G8969
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G8969"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G9927":
  /*
   * config_link_id: G9927
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9927"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9928":
  /*
   * config_link_id: G9928
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: G8967"
  and not "Denominator Exception: G8968"
  and not "Denominator Exception: G8969"
