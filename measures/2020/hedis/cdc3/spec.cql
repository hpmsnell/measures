library HEDIS_CDC3_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC3
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

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
valueset "HEDIS; Frailty"
valueset "HEDIS; Advanced Illness"
valueset "HEDIS; Outpatient"
valueset "HEDIS; Observation"
valueset "HEDIS; ED"
valueset "HEDIS; Nonacute Inpatient"
valueset "HEDIS; Acute Inpatient"

valueset "MIPS; Performance Not Met: 3044F" //HbA1c <7


parameter "Measurement Period" Interval<DateTime>

context Patient

define "Last HbA1c Result":
  Last(["Laboratory Test, Performed": "HEDIS; HbA1c Tests"] L
    where L.resultDateTime during "Measurement Year"
      and not L.result = null
    sort by L.resultDateTime asc
    return L.result)

/* Populations */

define "Exclusion: Hospice":
	   /*
	   * config_link_id: exclusion_required_hospice
	   */
	   exists("Hospice During Period"("Measurement Period"))

define "Denominator":
  "HEDIS CDC1: Denominator"

define "Denominator Exclusion: Diagnosis"
  /*
  * config_link_id: exclusion_1
  */
  "HEDIS CDC1: Denominator Exclusion: Diagnosis"

define "Denominator Exclusion: Frailty or Advanced Illness"
  /*
  * config_link_id: exclusion_2
  */
  "HEDIS CDC1: Denominator Exclusion: Frailty or Advanced Illness"

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
  not "Denominator Exclusion: Diagnosis"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met: Controlled HbA1c"
  and not "Numerator Performance Not Met: High HbA1c"
