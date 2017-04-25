library MIPS_236_Diastolic version '1'

/*
 * Source: MIPS
 * ID: 236
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By: Cal Newman
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 236 Encounter"
valueset "MIPS; Hypertension"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Clinical Exclusion: G9231"
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
valueset "VSAC; Adult Outpatient Encounter": '2.16.840.1.113883.3.464.1003.101.12.1065'
valueset "VSAC; Diastolic Blood Pressure": '2.16.840.1.113883.3.526.3.1033'
valueset "VSAC; Systolic Blood Pressure": '2.16.840.1.113883.3.526.3.1032'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 236 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and AgeInYearsAt(start of E.relevantPeriod) < 85
      and E.signingProvider.pqrsProvider = true

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

define "Denominator":
  exists("Denominator Encounter")
  and exists(["Diagnosis": "MIPS; Hypertension"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion 1":
  /*
   * config_link_id: exclusion_1
   */
 exists(["Procedure, Performed": "MIPS; MIPS Hospice Service: G9740"] I
   where I.relevantPeriod starts during "Measurement Period")
 or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
   where I.relevantPeriod overlaps "Measurement Period")

 define "Denominator Exclusion 2":
   /*
    * config_link_id: exclusion_2
    */
  exists(["Procedure, Performed": "Clinical Exclusion: G9231"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists("Excluded Diagnoses" D
    where D.prevalencePeriod starts before end "Measurement Period")
  or exists("Excluded Procedures" P
    where P.relevantPeriod starts before end "Measurement Period")
  or exists(["Diagnosis": "VSAC; Pregnancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Good Most Recent Diastolic Blood Pressure":
  Last("Encounter, Performed": "VSAC; Adult Outpatient Visit") E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] D
      such that
        D.relevantPeriod starts during E.relevantPeriod
        and D.result < 90

define "Bad Most Recent Diastolic Blood Pressure":
  Last("Encounter, Performed": "VSAC; Adult Outpatient Visit") E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] D
      such that
        D.relevantPeriod starts during E.relevantPeriod
        and D.result >= 90

define "Good Most Recent Systolic Blood Pressure":
  Last("Encounter, Performed": "VSAC; Adult Outpatient Visit") E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Physical Exam, Performed": "VSAC; Systolic Blood Pressure"] S
      such that
        S.relevantPeriod starts during E.relevantPeriod
        and S.result < 140

define "Bad Most Recent Systolic Blood Pressure":
  Last("Encounter, Performed": "VSAC; Adult Outpatient Visit") E
    where E.relevantPeriod starts during "Measurement Period"
    with ["Physical Exam, Performed": "VSAC; Systolic Blood Pressure"] S
      such that
        S.relevantPeriod starts during E.relevantPeriod
        and S.result >= 140

define "Numerator Performance Met: G8752 and G8754":
  /*
   * config_link_id: G8752/G8754
   */
  (
    exists(["Procedure, Performed": "MIPS; Performance Met: G8752"] P
      where P.relevantPeriod starts during "Measurement Period")
    or exists("Good Most Recent Systolic Blood Pressure")
  )
  and (
    exists(["Procedure, Performed": "MIPS; Performance Met: G8754"] P
      where P.relevantPeriod starts during "Measurement Period")
    or exists("Good Most Recent Diastolic Blood Pressure")
  )

define "Numerator Performance Not Met: G8753 and G8754":
  /*
   * config_link_id: G8753/G8754
   */
   (
     exists(["Procedure, Performed": "MIPS; Performance Met: G8753"] P
       where P.relevantPeriod starts during "Measurement Period")
     or exists("Bad Most Recent Systolic Blood Pressure")
   )
   and (
     exists(["Procedure, Performed": "MIPS; Performance Met: G8754"] P
       where P.relevantPeriod starts during "Measurement Period")
     or exists("Good Most Recent Diastolic Blood Pressure")
   )

define "Numerator Performance Not Met: G8752 and G8755":
  /*
   * config_link_id: G8752/G8755
   */
   (
     exists(["Procedure, Performed": "MIPS; Performance Met: G8752"] P
       where P.relevantPeriod starts during "Measurement Period")
     or exists("Good Most Recent Systolic Blood Pressure")
   )
   and (
     exists(["Procedure, Performed": "MIPS; Performance Met: G8755"] P
       where P.relevantPeriod starts during "Measurement Period")
     or exists("Bad Most Recent Diastolic Blood Pressure")
   )

define "Numerator Performance Not Met: G8753 and G8755":
  /*
   * config_link_id: G8753/G8755
   */
   (
     exists(["Procedure, Performed": "MIPS; Performance Met: G8753"] P
       where P.relevantPeriod starts during "Measurement Period")
     or exists("Bad Most Recent Systolic Blood Pressure")
   )
   and (
     exists(["Procedure, Performed": "MIPS; Performance Met: G8755"] P
       where P.relevantPeriod starts during "Measurement Period")
     or exists("Bad Most Recent Diastolic Blood Pressure")
   )

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
