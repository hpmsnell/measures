library HEDIS_CBP_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CBP
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; Performance Met: G8752" //Systolic BP <140
valueset "MIPS; Performance Not Met: G8753" //Systolic BP >=140
valueset "MIPS; Performance Met: G8754" //Diastolic BP <90
valueset "MIPS; Performance Not Met: G8755" //Diastolic BP >=90
valueset "MIPS; Performance Met: G8783" //Normal BP
valueset "MIPS; Performance Met: G8950" //Hypertensive BP
valueset "MIPS; Performance Not Met: G8952" //Hypertensive BP

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Outpatient Without UBREV": '2.16.840.1.113883.3.464.1004.1203'
valueset "HEDIS; Essential Hypertension": '2.16.840.1.113883.3.464.1004.1122'
valueset "HEDIS; ESRD": '2.16.840.1.113883.3.464.1004.1089'
valueset "HEDIS; ESRD Obsolete": '2.16.840.1.113883.3.464.1004.1090'
valueset "HEDIS; Kidney Transplant": '2.16.840.1.113883.3.464.1004.1141'
valueset "HEDIS; Pregnancy": '2.16.840.1.113883.3.464.1004.1219'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Systolic Less Than 140"
valueset "HEDIS; Systolic Greater Than/Equal To 140"
valueset "HEDIS; Diastolic Less Than 80"
valueset "HEDIS; Diastolic 80-89"
valueset "HEDIS; Diastolic Greater Than/Equal To 90"

// VSAC value test_set_keys

valueset "VSAC; Diastolic Blood Pressure": '2.16.840.1.113883.3.526.3.1033'
valueset "VSAC; Systolic Blood Pressure": '2.16.840.1.113883.3.526.3.1032'


parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]


define "Encounter with Hypertension":
  ["Encounter, Performed": "HEDIS; Outpatient Without UBREV"] E
    where E.relevantPeriod starts during [start of "Measurement Period", 6 months before end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Essential Hypertension"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "ESRD Procedure":
  ["Procedure, Performed": "HEDIS; ESRD"]
  union ["Procedure, Performed": "HEDIS; ESRD Obsolete"]
  union ["Procedure, Performed": "HEDIS; Kidney Transplant"]

define "Nonacute Visit":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]

define "Diabetes Exists":
  exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  or count("Nonacute Visit" E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during E.relevantPeriod) >= 2

define "Systolic Blood Pressure":
  ["Assessment, Performed": "VSAC; Systolic Blood Pressure"]
  union ["Procedure, Performed": "HEDIS; Systolic Less Than 140"]
  union ["Procedure, Performed": "HEDIS; Systolic Greater Than/Equal To 140"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8752"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8753"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8783"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8950"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8952"]

define "Normal Systolic Blood Pressure Procedure":
  ["Procedure, Performed": "HEDIS; Systolic Less Than 140"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8752"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8783"]

define "Most Recent Systolic":
  Last("Systolic Blood Pressure" A
    with "Encounter with Hypertension" E
      such that A.authorDateTime after start of E.relevantPeriod
    where A.authorDateTime during "Measurement Period"
    sort by A.authorDateTime asc)

define "Diastolic Blood Pressure":
  ["Assessment, Performed": "VSAC; Diastolic Blood Pressure"]
  union ["Procedure, Performed": "HEDIS; Diastolic Less Than 80"]
  union ["Procedure, Performed": "HEDIS; Diastolic 81-89"]
  union ["Procedure, Performed": "HEDIS; Diastolic Greater Than/Equal To 90"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8754"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8755"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8783"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8950"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G8952"]

define "Normal Diastolic Blood Pressure Procedure":
  ["Procedure, Performed": "HEDIS; Diastolic Less Than 80"]
  union ["Procedure, Performed": "HEDIS; Diastolic 81-89"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8754"]
  union ["Procedure, Performed": "MIPS; Performance Met: G8783"]

define "Most Recent Diastolic":
  Last("Diastolic Blood Pressure" A
    with "Encounter with Hypertension" E
      such that A.authorDateTime after start of E.relevantPeriod
    where A.authorDateTime during "Measurement Period"
    sort by A.authorDateTime asc)

define "Patient over 60 without Diabetes"
  AgeInYearsAt(end of "Measurement Period") >= 60
  and not "Diabetes Exists"

define "Systolic Blood Pressure < 140":
  exists("Most Recent Systolic" A1
    with ["Assessment, Performed": "VSAC; Systolic Blood Pressure"] A2
      such that A2.authorDateTime same day as A1.authorDateTime
        and A2.result < 140)
  or exists("Most Recent Systolic" A1
    with "Normal Systolic Blood Pressure Procedure" A2
      such that A2.authorDateTime same day as A1.authorDateTime)

define "Systolic Blood Pressure < 150":
  exists("Most Recent Systolic" A1
    with ["Assessment, Performed": "VSAC; Systolic Blood Pressure"] A2
      such that A2.authorDateTime same day as A1.authorDateTime
        and A2.result < 150)
  or exists("Most Recent Systolic" A1
    with "Normal Systolic Blood Pressure Procedure" A2
      such that A2.authorDateTime same day as A1.authorDateTime)

define "Diastolic Blood Pressure < 90":
  exists("Most Recent Diastolic" A1
    with ["Assessment, Performed": "VSAC; Diastolic Blood Pressure"] A2
      such that A2.authorDateTime same day as A1.authorDateTime
        and A2.result < 90)
  or exists("Most Recent Diastolic" A1
    with "Normal Diastolic Blood Pressure Procedure" A2
      such that A2.authorDateTime same day as A1.authorDateTime)

define "Blood Pressure < 140/90":
  "Systolic Blood Pressure < 140"
  and "Diastolic Blood Pressure < 90"

define "Blood Pressure < 150/90":
  "Patient over 60 without Diabetes"
  and "Systolic Blood Pressure < 150"
  and "Diastolic Blood Pressure < 90"

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 18
  and AgeInYearsAt(end of "Measurement Period") < 86
  and exists("Encounter with Hypertension")
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: ESRD":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Diagnosis": "HEDIS; ESRD"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists("ESRD Procedure" P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Denominator Exclusion: Pregnancy":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Diagnosis": "HEDIS; Pregnancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion: Inpatient Visit":
  /*
   * config_link_id: exclusion_3
   */
  exists(["Encounter, Performed": "HEDIS; Inpatient Stay"] E1
    where E1.relevantPeriod starts during "Measurement Period"
    with ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] E2
      such that E2.relevantPeriod starts during E1.relevantPeriod)

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Blood Pressure < 140/90"
  or "Blood Pressure < 150/90"

define "Numerator Performance Not Met: Out of Range":
  /*
   * config_link_id: out_of_range
   */
  exists("Systolic Blood Pressure" A
    where A.authorDateTime during "Measurement Period")
  and exists("Diastolic Blood Pressure" A
    where A.authorDateTime during "Measurement Period")

define "Numerator Performance Not Met: No Blood Pressure":
  /*
   * config_link_id: no_blood_pressure
   */
  not "Denominator Exclusion: ESRD"
  and not "Denominator Exclusion: Pregnancy"
  and not "Denominator Exclusion: Inpatient Visit"
  and not "Numerator Performance Met"
  and not "Numerator Performance Not Met: Out of Range"
