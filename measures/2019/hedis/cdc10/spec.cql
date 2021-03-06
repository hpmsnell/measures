library HEDIS_CDC10_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC10
 * Year: 2019
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
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'

valueset "MIPS; Performance Not Met: 3044F" //HbA1c <7
valueset "NCQA; Diabetes Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "HbA1c Lab Test":
  (["Assessment, Performed": "HEDIS; HbA1c Test Result or Finding"]
  union ["Laboratory Test, Performed": "HEDIS; HbA1c Lab Test"] HbA1cLab
    where HbA1cLab.result != null) HbA1cTest
    where HbA1cTest.relevantDatetime during "Measurement Period"

define "Last HbA1c Test":
  Last("HbA1c Lab Test" LastHbA1cTest
    sort by LastHbA1cTest.relevantDateTime asc)

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
  exists("Last HbA1c Test" HbA1C
     where HbA1C.result < 8
       or HbA1C.code in "HEDIS; HbA1c Level Less Than 8.0")
  or exists([Procedure, Performed: "MIPS; Performance Not Met: 3044F"] P
    where P.relevantPeriod starts during "Measurement Period"
      and P.code.modifier not in "HEDIS; CPT Cat II Modifier"
      and P.placeOfService != '81')

define "Numerator Performance Not Met: High HbA1c":
  /*
   * config_link_id: hba1c_high
   */
  exists("Last HbA1c Test" HbA1C
     where HbA1C.result >= 8
      or exists HbA1C.code in "HEDIS; HbA1c Level Greater Than 9.0"
      or exists HbA1C.code "HEDIS; HbA1c Level 7.0-9.0")

define "Numerator Performance Not Met: No HbA1c":
  /*
   * config_link_id: hba1c_none
   */
  not exists("HbA1c Lab Test")

define "Numerator Performance Not Met: Uncontrolled HbA1c":
  /*
  * config_link_id: hba1c_uncontrolled
  */
  not "Denominator Exclusion: Diagnosis"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met: Controlled HbA1c"
  and not "Numerator Performance Not Met: High HbA1c"
  and not "Numerator Performance Not Met: No HbA1c"
