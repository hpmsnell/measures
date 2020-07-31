library HEDIS_CDC2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC2
 * Year: 2020
 * Version: 1
 * Author: Chana West
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
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; HbA1c Lab Test": '2.16.840.1.113883.3.464.1004.1755'
valueset "HEDIS; HbA1c Test Result or Finding": '2.16.840.1.113883.3.464.1004.1756'
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; HbA1c Level Less Than 7.0": '2.16.840.1.113883.3.464.1004.1115'
valueset "HEDIS; HbA1c Level 7.0-9.0": '2.16.840.1.113883.3.464.1004.1113'
valueset "HEDIS; HbA1c Level Greater Than 9.0": '2.16.840.1.113883.3.464.1004.1114'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "HbA1c Lab Test":
  ["Assessment, Performed": "HEDIS; HbA1c Test Result or Finding"]
  union "Laboratory Test, Performed": "HEDIS; HbA1c Lab Test"

define "Last HbA1c Result":
  Last("HbA1c Lab Test" L
    where L.resultDateTime during "Measurement Year"
      and not L.result = null
    sort by L.resultDateTime asc
    return L.result)

define "HbA1C Result Less or Equal to 9":
  ["Assessment, Performed": "HEDIS; HbA1c Level Less Than 7.0"]
  union ["Assessment, Performed": "HEDIS; HbA1c Level 7.0-9.0"

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

define "Numerator Performance Met: High HbA1c":
  /*
   * config_link_id: hba1c_high
   */
  "Last HbA1c Result" > 9
  union ["Assessment, Performed": "HEDIS; HbA1c Level Greater Than 9.0"]

define "Numerator Performance Met: No HbA1c Completed":
  /*
   * config_link_id: hba1c_none
   */
  not exists("HbA1c Lab Test" NoLab
    where NoLab.relevantDateTime during "Measurement Period"
      or NoLab.authorDateTime during "Measurement Period"
  )

define "Numerator Performance Met: No HbA1c Result":
  /*
   * config_link_id: hba1c_no_result
   */
  exists(["Laboratory Test, Performed": "HEDIS; HbA1c Lab Test"] L
    where L.relevantDateTime during "Measurement Period"
      and result = null)

define "Numerator Performance Not Met: Controlled HbA1c":
  /*
   * config_link_id: hba1c_controlled
   */
  "HbA1C Result Less or Equal to 9"
  and not "Numerator Performance Met: High HbA1c"
  and not "Numerator Performance Met: No HbA1c Completed"
  and not "Numerator Performance Met: No HbA1c Result"
