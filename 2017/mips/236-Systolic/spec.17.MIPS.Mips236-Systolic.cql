library MIPS_236_Systolic_2017 version '#'

/*
 * Source: MIPS
 * ID: 236-Systolic
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By: Rachel Katz
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 236 Encounters"
valueset "MIPS; Hypertension"
valueset "MIPS; Hospice Service: G9740"
valueset "MIPS; Clinical Exclusion: G9231"
valueset "MIPS; Performance Met: G8752"
valueset "MIPS; Performance Not Met: G8753"
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
valueset "VSAC; Adult Outpatient Encounter": '2.16.840.1.113883.3.464.1003.101.12.1065'
valueset "VSAC; Systolic Blood Pressure": '2.16.840.1.113883.3.526.3.1032'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  AgeInYearsAt(
    ["Encounter, Performed": "MIPS; MIPS 236 Encounter"] E
      where E.relevantPeriod starts during "Measurement Period"
  )

define "Excluded Diagnoses":
  ["Diagnosis": "VSAC; Pregnancy"]
  union ["Diagnosis": "VSAC; End Stage Renal Disease"]
  union ["Diagnosis": "VSAC; Chronic Kidney Disease, Stage 5"]

define "Excluded Procedures":
  ["Procedure, Performed": "VSAC; Vascular Access for Dialysis"]
  union ["Procedure, Performed": "VSAC; ESRD Monthly Outpatient Services"]
  union ["Procedure, Performed": "VSAC; Kidney Transplant"]
  union ["Procedure, Performed": "VSAC; Dialysis Services"]
  union ["Intervention, Performed": "VSAC; Other Services Related to Dialysis"]
  union ["Intervention, Performed": "VSAC; Dialysis Education"]

define "Denominator":
  "Patient Age at Encounter" >= 18
  and "Patient Age at Encounter" < 85
  and exists(["Diagnosis": "MIPS; Hypertension"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion 1":
  /*
   * config_link_id: denominator_exclusion_1
   */
 exists(["Procedure, Performed": "MIPS; Hospice Service: G9740"] I
   where I.relevantPeriod starts during "Measurement Period")
 or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
   where I.relevantPeriod overlaps "Measurement Period")

 define "Denominator Exclusion 2":
   /*
    * config_link_id: denominator_exclusion_2
    */
  exists(["Procedure, Performed": "Clinical Exclusion: G9231"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists("Excluded Diagnoses" D
    where D.prevalencePeriod overlaps "Measurement Period")
  or exists("Excluded Procedures" P
    where P.relevantPeriod starts before end "Measurement Period")

define "Numerator Performance Met: G8752":
  /*
   * config_link_id: G8752
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8752"] P
    where P.relevantPeriod starts during "Measurement Period")
  or Last("Encounter, Performed": "VSAC; Adult Outpatient Visit") E
    with ["Physical Exam, Performed": "VSAC; Systolic Blood Pressure"] P
      such that P.relevantPeriod starts during E.relevantPeriod
        and P.result < 140

define "Numerator Performance Not Met: G8753":
  /*
   * config_link_id: G8753
   */
  exists("Procedure, Performed": "MIPS; Performance Met: G8753"] P
    where P.relevantPeriod starts during "Measurement Period")
  or Last("Encounter, Performed": "VSAC; Adult Outpatient Visit") E
    with ["Physical Exam, Performed": "VSAC; Systolic Blood Pressure"] P
      such that P.relevantPeriod starts during E.relevantPeriod
        and P.result >= 140

define "Numerator Performance Not Met: G8756":
  /*
   * config_link_id: G8756
   */
  not "Denominator Exclusion 1"
  and not "Denominator Exclusion 2"
  and not "Numerator Performance Met: G8752"
  and not "Numerator Performance Not Met: G8753"
