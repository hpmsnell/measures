library MIPS_236_2020 version '1'

/*
 * Source: MIPS
 * ID: 236
 * Year: 2020
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 236 Encounter"
valueset "MIPS; Hypertension"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Clinical Exclusion: G9231"
valueset "MIPS; Institutional Exclusion"
valueset "MIPS; Performance Met: G8752"
valueset "MIPS; Performance Not Met: G8753"
valueset "MIPS; Performance Met: G8754"
valueset "MIPS; Performance Not Met: G8755"
valueset "MIPS; Performance Not Met: G8756"

// VSAC Value Sets

valueset "VSAC; Pregnancy": '2.16.840.1.113883.3.526.3.378'
valueset "VSAC; End Stage Renal Disease": '2.16.840.1.113883.3.526.3.353'
valueset "VSAC; Chronic Kidney Disease, Stage 5": '2.16.840.1.113883.3.526.3.1002'
valueset "VSAC; Vascular Access for Dialysis": '2.16.840.1.113883.3.464.1003.109.12.1011'
valueset "VSAC; ESRD Monthly Outpatient Services": '2.16.840.1.113883.3.464.1003.109.12.1014'
valueset "VSAC; Kidney Transplant": '2.16.840.1.113883.3.464.1003.109.12.1012'
valueset "VSAC; Dialysis Services": '2.16.840.1.113883.3.464.1003.109.12.1013'
valueset "VSAC; Other Services Related to Dialysis": '2.16.840.1.113883.3.464.1003.109.12.1015'
valueset "VSAC; Dialysis Education": '2.16.840.1.113883.3.464.1003.109.12.1016'
valueset "VSAC; Diastolic Blood Pressure": '2.16.840.1.113883.3.526.3.1033'
valueset "VSAC; Systolic Blood Pressure": '2.16.840.1.113883.3.526.3.1032'
valueset "VSAC; Acute Inpatient": '2.16.840.1.113883.3.464.1003.101.12.1083'
valueset "VSAC; Advanced Illness": '2.16.840.1.113883.3.464.1003.110.12.1082'
valueset "VSAC; Care Services in Long-Term Residential Facility": '2.16.840.1.113883.3.464.1003.101.12.1014'
valueset "VSAC; Dementia Medications": '2.16.840.1.113883.3.464.1003.196.12.1510'
valueset "VSAC; Encounter Inpatient": '2.16.840.1.113883.3.666.5.307'
valueset "VSAC; Frailty Diagnosis": '2.16.840.1.113883.3.464.1003.113.12.1074'
valueset "VSAC; Frailty Encounter": '2.16.840.1.113883.3.464.1003.101.12.1088'
valueset "VSAC; Nonacute Inpatient": '2.16.840.1.113883.3.464.1003.101.12.1084'
valueset "VSAC; Nursing Facility Visit": '2.16.840.1.113883.3.464.1003.101.12.1012'
valueset "VSAC; Observation": '2.16.840.1.113883.3.464.1003.101.12.1086'
valueset "VSAC; Outpatient": '2.16.840.1.113883.3.464.1003.101.12.1087'
valueset "VSAC; Encounter Inpatient": '2.16.840.1.113883.3.666.5.307'
valueset "VSAC; ED": '2.16.840.1.113883.3.464.1003.101.12.1085'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 236 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and AgeInYearsAt(start of E.relevantPeriod) < 85
      and E.signingProvider.hasMeasureMembership = true
      and not E.placeOfService in {'32','33','34','54','56'}

define "Excluded Diagnoses":
  ["Diagnosis": "VSAC; End Stage Renal Disease"]
  union ["Diagnosis": "VSAC; Chronic Kidney Disease, Stage 5"]

define "Excluded Procedures":
  ["Procedure, Performed": "VSAC; Vascular Access for Dialysis"]
  union ["Procedure, Performed": "VSAC; ESRD Monthly Outpatient Services"]
  union ["Procedure, Performed": "VSAC; Kidney Transplant"]
  union ["Procedure, Performed": "VSAC; Dialysis Services"]
  union ["Intervention, Performed": "VSAC; Other Services Related to Dialysis"]
  union ["Intervention, Performed": "VSAC; Dialysis Education"]

define "Diastolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8754"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8755"]

define "Systolic Blood Pressure":
  ["Physical Exam, Performed": "VSAC; Sytolic Blood Pressure"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8752"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8753"]

define "Inpatient Encounter":
  ["Encounter, Performed": "VSAC; Encounter Inpatient"]
  union ["Encounter, Performed": "VSAC; ED"]

define "Most Recent Diastolic Blood Pressure"
  Last("Diastolic Blood Pressure" BloodPressure
    where BloodPressure.relevantPeriod starts during "Measurement Period"
    without "Inpatient Encounter" Encounter
      such that BloodPressure.authorDatetime during Encounter.relevantPeriod
    sort by BloodPressure.authorDatetime asc)

define "Most Recent Systolic Blood Pressure"
  Last("Systolic Blood Pressure" BloodPressure
    where BloodPressure.relevantPeriod starts during "Measurement Period"
    without "Inpatient Encounter" Encounter
      such that BloodPressure.authorDatetime during Encounter.relevantPeriod
    sort by BloodPressure.authorDatetime asc)

define "Normal Most Recent Diastolic Blood Pressure Exists":
  exists("Most Recent Diastolic Blood Pressure" BloodPressure
    where BloodPressure.result < 90)
  or exists("Most Recent Diastolic Blood Pressure" BloodPressure
    where BloodPressure.code in "MIPS; Performance Met: G8754")

define "Abnormal Most Recent Diastolic Blood Pressure Exists":
  exists("Most Recent Diastolic Blood Pressure" BloodPressure
    where BloodPressure.result >= 90)
  or exists("Most Recent Diastolic Blood Pressure" BloodPressure
    where BloodPressure.code in "MIPS; Performance Not Met: G8755")

define "Normal Most Recent Systolic Blood Pressure Exists":
  exists("Most Recent Systolic Blood Pressure" BloodPressure
    where BloodPressure.result < 140)
  or exists("Most Recent Systolic Blood Pressure" BloodPressure
    where BloodPressure.code in "MIPS; Performance Met: G8752")

define "Abnormal Most Recent Systolic Blood Pressure Exists":
  exists("Most Recent Systolic Blood Pressure" BloodPressure
    where BloodPressure.result >= 140)
  or exists("Most Recent Systolic Blood Pressure" BloodPressure
    where BloodPressure.code in "MIPS; Performance Not Met: G8753")

/* Populations */

define "Denominator":
  exists("Denominator Encounter")
  and exists(["Diagnosis": "MIPS; Hypertension"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion: Hospice":
  /*
   * config_link_id: exclusion_1
   */
 exists(["Procedure, Performed": "MIPS; MIPS Hospice Service: G9740"] I
   where I.relevantPeriod starts during "Measurement Period")
 or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
   where I.relevantPeriod overlaps "Measurement Period")

 define "Denominator Exclusion: Clinical":
   /*
    * config_link_id: exclusion_2
    */
  exists(["Procedure, Performed": "Clinical Exclusion: G9231"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists("Excluded Diagnoses" D
    where D.prevalencePeriod starts on or before end "Measurement Period")
  or exists("Excluded Procedures" P
    where P.relevantPeriod starts on or before end "Measurement Period")
  or exists(["Diagnosis": "VSAC; Pregnancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion: Frailty/LTI":
  /*
   * config_link_id: exclusion_frailty_lti
   */
  FrailtyLTIShared."Frailty/LTI Exclusion Exists"

define "Numerator Performance Met: G8752 and G8754":
  /*
   * config_link_id: G8752/G8754
   */
  "Normal Most Recent Systolic Blood Pressure Exists"
  and "Normal Most Recent Diastolic Blood Pressure Exists"

define "Numerator Performance Not Met: G8753 and G8754":
  /*
   * config_link_id: G8753/G8754
   */
   "Abnormal Most Recent Systolic Blood Pressure Exists"
   and "Normal Most Recent Diastolic Blood Pressure Exists"

define "Numerator Performance Not Met: G8752 and G8755":
  /*
   * config_link_id: G8752/G8755
   */
   "Normal Most Recent Systolic Blood Pressure Exists"
   and "Abnormal Most Recent Diastolic Blood Pressure Exists"

define "Numerator Performance Not Met: G8753 and G8755":
  /*
   * config_link_id: G8753/G8755
   */
   "Abnormal Most Recent Systolic Blood Pressure Exists"
   and "Abnormal Most Recent Diastolic Blood Pressure Exists"

define "Numerator Performance Not Met: G8756":
  /*
   * config_link_id: G8756
   */
  not "Denominator Exclusion 1"
  and not "Denominator Exclusion 2"
  and not "Numerator Performance Met: G8752 and G8754"
  and not "Numerator Performance Not Met: G8752 and G8755"
  and not "Numerator Performance Not Met: G8753 and G8754"
  and not "Numerator Performance Not Met: G8753 and G8755"
