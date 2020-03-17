library HEDIS_CDC6_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC6
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; Performance Met: G8506" //ACE Inhibitor

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Urine Protein Tests": '2.16.840.1.113883.3.464.1004.1400'
valueset "HEDIS; Nephropathy Treatment": '2.16.840.1.113883.3.464.1004.1184'
valueset "HEDIS; CKD Stage 4": '2.16.840.1.113883.3.464.1004.1052'
valueset "HEDIS; ESRD": '2.16.840.1.113883.3.464.1004.1089'
valueset "HEDIS; Kidney Transplant": '2.16.840.1.113883.3.464.1004.1141'
valueset "HEDIS; Diabetes Medications": '2.16.840.1.113883.3.464.1004.2050'
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; Frailty Device": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Diagnosis": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Encounter": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Symptom": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Advanced Illness": '2.16.840.1.113883.3.464.1004.1465'
valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Telehealth POS": '2.16.840.1.113883.3.464.1004.1460'
valueset "HEDIS; Telehealth Modifier": '2.16.840.1.113883.3.464.1004.1445'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "Dementia Medications": '2.16.840.1.113883.3.464.1004.1729'

// NCQA medication list value sets

valueset "NCQA; ACE Inhibitor/ARB Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Nephropathy Procedures":
  ["Assessment, Performed": "HEDIS; Urine Protein Tests"]
  union ["Procedure, Performed": "HEDIS; Nephropathy Treatment"]
  union ["Procedure, Performed": "HEDIS; ESRD"]
  union ["Procedure, Performed": "HEDIS; Kidney Transplant"]

define "Nephropathy Diagnoses":
  ["Diagnosis": "HEDIS; CKD Stage 4"]
  union ["Diagnosis": "HEDIS; Nephropathy Treatment"]
  union ["Diagnosis": "HEDIS; ESRD"]

define "Denominator":
  "HEDIS CDC1: Denominator"

/*
 * config_link_id: exclusion_required_hospice
 */
define "Exclusion: Hospice":
  "HEDIS CDC1: Exclusion: Hospice"


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

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Laboratory Test, Performed": "HEDIS; Urine Protein Tests"] L
    where L.resultDateTime during "Measurement Year")
  or exists("Nephropathy Procedures" P
    where P.relevantPeriod starts during "Measurement Year")
  or exists("Nephropathy Diagnoses" D
    where D.prevalencePeriod overlaps "Measurement Year")
  or exists(["Medication, Dispensed": "NCQA; ACE Inhibitor/ARB Medications"] M
    where M.relevantPeriod starts during "Measurement Year")
  or exists(["Procedure": "MIPS; Performance Met: G8506"] P
    where P.relevantPeriod starts during "Measurement Year")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Diagnosis"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met"
