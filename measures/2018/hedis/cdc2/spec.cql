library HEDIS_CDC2_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC2
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
valueset "HEDIS; HbA1c Level Less Than 7.0"
valueset "HEDIS; HbA1c Level 7.0-9.0"
valueset "HEDIS; HbA1c Level Greater Than 9.0"

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

THIS IS A TEST CHANGE FOR CHANA

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Last HbA1c Result":
  Last(["Laboratory Test, Performed": "HEDIS; HbA1c Tests"] L
    where L.resultDateTime during "Measurement Year"
      and not L.result = null
    sort by L.resultDateTime asc
    return L.result)

define "Eligible HbA1c Procedures":
  ["Procedure, Performed": "HEDIS; HbA1c Level Less Than 7.0"]
  union ["Procedure, Performed": "HEDIS; HbA1c Level 7.0-9.0"]
  union ["Procedure, Performed": "HEDIS; HbA1c Level Greater Than 9.0"]

define "Denominator":
  "HEDIS CDC1: Denominator"

define "Denominator Exclusion: Diagnosis"
  /*
  * config_link_id: exclusion_1
  */
  "HEDIS CDC1: Denominator Exclusion: Diagnosis"

define "Numerator Performance Met: High HbA1c":
  /*
   * config_link_id: hba1c_high
   */
  "Last HbA1c Result" > 9

define "Numerator Performance Met: No HbA1c":
  /*
   * config_link_id: hba1c_none
   */
  not exists(["Laboratory Test, Performed": "HEDIS; HbA1c Tests"] L
    where L.resultDateTime during "Measurement Year"
      and not result = null)

define "Numerator Performance Not Met: Controlled HbA1c":
  /*
   * config_link_id: hba1c_controlled
   */
  not "Numerator Performance Met"
