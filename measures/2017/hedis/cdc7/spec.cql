library HEDIS_CDC7_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC7
 * Year: 2017
 * Version: 1
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
valueset "HEDIS; Diabetes Medications"
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'
valueset "HEDIS; Systolic Less Than 140": ''
valueset "HEDIS; Systolic Greater Than/Equal To 140": ''
valueset "HEDIS; Diastolic Less Than 80": ''
valueset "HEDIS; Diastolic 80-89": ''
valueset "HEDIS; Diastolic Greater Than/Equal To 90": ''

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Diastolic Blood Pressure": '2.16.840.1.113883.3.526.3.1033'
valueset "VSAC; Systolic Blood Pressure": '2.16.840.1.113883.3.526.3.1032'

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

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

define "Denominator Exclusion: Diagnosis"
  /*
  * config_link_id: exclusion_1
  */
  "HEDIS CDC1: Denominator Exclusion: Diagnosis"

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
  not "Numerator Performance Met: Normal Blood Pressure"
  and not "Numerator Performance Not Met: High Blood Pressure"
