library HEDIS_CDC7_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC7
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Diabetes Medications": ''
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; Systolic Less Than 140": '2.16.840.1.113883.3.464.1004'
valueset "HEDIS; Systolic Greater Than or Equal To 140": '2.16.840.1.113883.3.464.1004'
valueset "HEDIS; Diastolic Less Than 80": '2.16.840.1.113883.3.464.1004.1084'
valueset "HEDIS; Diastolic 80-89": '2.16.840.1.113883.3.464.1004.1082'
valueset "HEDIS; Diastolic Greater Than or Equal To 90": '90,2.16.840.1.113883.3.464.1004.1083'
valueset "HEDIS; Frailty Device": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Diagnosis": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Encounter": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Frailty Symptom": '2.16.840.1.113883.3.464.1004.1530'
valueset "HEDIS; Advanced Illness": '2.16.840.1.113883.3.464.1004.1465'
valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'


// VSAC value sets

valueset "VSAC; Diastolic Blood Pressure": '2.16.840.1.113883.3.526.3.1033'
valueset "VSAC; Systolic Blood Pressure": '2.16.840.1.113883.3.526.3.1032'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Visit":
  ["Encounter, Performed": "Outpatient"]
  union ["Encounter, Performed": "Nonacute Inpatient"]

define "Systolic":
  ["Assessment, Performed": "HEDIS; Systolic Less Than 140"]
  union ["Assessment, Performed": "HEDIS; Systolic Greater Than/Equal To 140"]
  union ["Assessment, Performed": "VSAC; Systolic Blood Pressure"]

define "Diastolic":
  ["Assessment, Performed": "HEDIS; Diastolic Less Than 80"]
  union ["Assessment, Performed": "HEDIS; 80-89"]
  union ["Assessment, Performed": "HEDIS; Diastolic Greater Than 90"]
  union ["Assessment, Performed": "VSAC; Diastolic Blood Pressure"] A

define "Most Recent Systolic":
  First("Systolic" A
    where A.authorDateTime during "Measurement Period"
    with "Visit" E
      such that A.authorDateTime during E.relevantPeriod
    sort by A.authorDateTime desc)

define "Most Recent Disastolic":
  First("Diastolic" A
    where A.authorDateTime during "Measurement Period"
    with "Visit" E
      such that A.authorDateTime during E.relevantPeriod
    sort by A.authorDateTime desc)

/* Blood pressure exists */

define "Systolic Exists":
  exists("Systolic" A
    where A.authorDateTime during "Measurement Period"
    with "Visit" E
      such that A.authorDateTime during E.relevantPeriod)

define "Diastolic Exists":
  exists("Diastolic" A
    where A.authorDateTime during "Measurement Period"
    with "Visit" E
      such that A.authorDateTime during E.relevantPeriod)

define "Most Recent Systolic Is Normal"
  exists("Most Recent Systolic" A
    where A.code in "HEDIS; Systolic Less Than 140"
      or A.result < 140)

define "Most Recent Diastolic Is Normal"
  exists("Most Recent Diastolic" A
    where A.code in "HEDIS; Diastolic Less Than 80"
      or A.code in "HEDIS; Diastolic 80-89"
      or A.result < 90)

/* Populations */

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

define "Numerator Performance Met: Normal Blood Pressure":
  /*
   * config_link_id: normal_blood_pressure
   */
  "Most Recent Systolic Is Normal"
  and "Most Recent Diastolic Is Normal"

define "Numerator Performance Not Met: High Blood Pressure":
  /*
   * config_link_id: high_blood_pressure
   */
  "Systolic Exists"
  and "Diastolic Exists"

define "Numerator Performance Not Met: No Blood Pressure":
  /*
   * config_link_id: no_blood_pressure
   */
  not "Denominator Exclusion: Diagnosis"
  and not "Denominator Exclusion: Frailty or Advanced Illness"
  and not "Numerator Performance Met: Normal Blood Pressure"
  and not "Numerator Performance Not Met: High Blood Pressure"
