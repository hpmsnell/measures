library HEDIS_CDC3_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC3
 * Year: 2018
 * Version: 2
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; HbA1c Tests": '2.16.840.1.113883.3.464.1004.1116'
valueset "HEDIS; Diabetes Medications"
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Not Met: 3044F" //HbA1c <7


parameter "Measurement Period" Interval<DateTime>

context Patient

define "Last HbA1c Result":
  Last(["Laboratory Test, Performed": "HEDIS; HbA1c Tests"] L
    where L.resultDateTime during "Measurement Year"
      and not L.result = null
    sort by L.resultDateTime asc
    return L.result)

define "Denominator":
  "HEDIS CDC1: Denominator"

define "Denominator Exclusion: Diagnosis"
  /*
  * config_link_id: exclusion_1
  */
  "HEDIS CDC1: Denominator Exclusion: Diagnosis"

define "Numerator Performance Met: Controlled HbA1c":
  /*
   * config_link_id: hba1c_controlled
   */
  "Last HbA1c Result" < 8
  or exists([Procedure, Performed: "MIPS; Performance Not Met: 3044F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: High HbA1c":
  /*
   * config_link_id: hba1c_high
   */
  "Last HbA1c Result" >= 8

define "Numerator Performance Not Met: No HbA1c":
  /*
   * config_link_id: hba1c_none
   */
  not "Numerator Performance Met: Controlled HbA1c"
  and not "Numerator Performance Not Met: High HbA1c"
