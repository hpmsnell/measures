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
valueset "MIPS; LVEF <40%"
valueset "MIPS; MIPS 326 Exclusion"
valueset "MIPS; Performance Met: G8967"
valueset "MIPS; Denominator Exception: G8968"
valueset "MIPS; Denominator Exception: G8969"
valueset "MIPS; Denominator Exception: G9927"
valueset "MIPS; Performance Not Met: G9928"

// VSAC value sets

valueset "VSAC; Anticoagulant Medications": '	2.16.840.1.113883.3.464.1003.196.11.1283'
valueset "VSAC; Cerebrovascular disease, Stroke, TIA": '2.16.840.1.113762.1.4.1047.44'
valueset "VSAC; Heart Failure": '2.16.840.1.113883.3.526.3.376'
valueset "VSAC; Moderate or Severe LVSD": '2.16.840.1.113883.3.526.3.1090'
valueset "VSAC; Diagnosis of hypertension": '2.16.840.1.113883.3.600.263'
valueset "VSAC; Diabetes": '2.16.840.1.113883.3.464.1003.103.12.1001'
valueset "VSAC; Anticoagulant ingredient specific": '2.16.840.1.113762.1.4.1021.9'

// Able value sets

valueset "Able; Mitral Stenosis"
valueset "Able; Prosthetic Heart Valve"
valueset "Able; Anticoagulant Allergy"
valueset "Able; Iron Deficiency Anemia"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 326 Encounter"] E
      where E.relevantPeriod starts during "Denominator Period"
        and AgeInYearsAt(start of E.relevantPeriod) >= 18
        and not E.code.modifier in {'GQ','GT','95'}
        and not E.placeOfService in {'02'}
        and E.signingProvider.hasMeasureMembership = true
      with ["Diagnosis": "MIPS; Nonvalvular Atrial Fibrillation or Atrial Flutter"] D
        such that D.prevalencePeriod overlaps E.relevantPeriod

define "Patient 75":
  AgeInYearsAt(start of "Denominator Period") >= 75

define "Hypertension Exists":
  exists(["Diagnosis": "VSAC; Diagnosis of hypertension"] D
    where D.prevalencePeriod overlaps "Denominator Period")

define "Diabetes Exists":
  exists(["Diagnosis": "VSAC; Diabetes"] D
    where D.prevalencePeriod overlaps "Denominator Period")

define "Heart Failure or LVSD"
  ["Diagnosis": "VSAC; Heart Failure"]
  union ["Diagnosis": "VSAC; Moderate or Severe LVSD"]

define "Heart Failure or LVSD Exists"
  exists("Heart Failure or LVSD" D
    where D.prevalencePeriod overlaps "Denominator Period")
  or exists(["Assessment, Performed": "MIPS; LVEF <40%"] A
    where A.relevantPeriod starts during "Denominator Period")

define "Hypertension, Diabetes, Heart Failure, or LVSD Exists"
  "Hypertension Exists"
  or "Diabetes Exists"
  or "Heart Failure or LVSD Exists"

define "Patient 75 with Hypertension, Diabetes, Heart Failure, or LVSD"
  "Patient 75"
  and "Hypertension, Diabetes, Heart Failure, or LVSD Exists"

define "Diabetes, Heart Failure, or LVSD Exists"
  "Diabetes Exists"
  or "Heart Failure or LVSD Exists"

define "Patient Hypertensive with Diabetes, Heart Failure, or LVSD"
  "Hypertension Exists"
  and "Diabetes, Heart Failure, or LVSD Exists"

define "Patient Diabetic with Heart Failure, or LVSD"
  "Diabetes Exists"
  and "Heart Failure or LVSD Exists"

define "High Risk Factors for Thromboembolism Exist"
  exists(["Assessment, Performed": "MIPS; Risk Factors for Thromboembolism"] A
    where A.relevantPeriod starts during "Denominator Period")
  or exists(["Diagnosis": "VSAC; Cerebrovascular disease, Stroke, TIA"] D
    where D.prevalencePeriod starts on or before end of "Denominator Period")
  or "Patient 75 with Hypertension, Diabetes, Heart Failure, or LVSD"
  or "Patient Hypertensive with Diabetes, Heart Failure, or LVSD"
  or "Patient Diabetic with Heart Failure, or LVSD"

/* Populations */

define "Denominator":
  exists("Denominator Encounter")
  and "High Risk Factors for Thromboembolism Exist"

define "Denominator Exclusion 1":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Assessment, Performed": "MIPS; MIPS 326 Exclusion"] A
    where A.relevantPeriod starts during "Denominator Period")
  or exists(["Diagnosis": "Able; Mitral Stenosis"] D
    where D.prevalencePeriod overlaps "Denominator Period")
  or exists(["Procedure, Performed": "Able; Prosthetic Heart Valve"] P
    where P.relevantPeriod starts on or before end of "Denominator Period")

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
