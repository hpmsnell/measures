library DEMO_CLOVER1_2018 version '1'

/*
 *
 * Source: Clover
 * ID: 1
 * Year: 2018
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
valueset "HEDIS; HbA1c Tests": '2.16.840.1.113883.3.464.1004.1116'
valueset "HEDIS; Diabetes Medications"
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// Able value sets

valueset "Able; Fasting Glucose"
valueset "Able; Systolic Blood Pressure"
valueset "Able; Diastolic Blood Pressure"
valueset "Able; Triglycerides"
valueset "Able; HDL-C"
valueset "Able; Waist Circumference"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Nonacute Visit":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Nonacute Inpatient"]

define "Patient Has Diabetes":
  exists(["Diagnosis": "HEDIS; Diabetes"] D
    where D.prevalencePeriod overlaps end of "Measurement Period")
  or exists(["Encounter, Performed": "HEDIS; Acute Inpatient"] E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during E.relevantPeriod)
  or count("Nonacute Visit" E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
    with ["Diagnosis": "HEDIS; Diabetes"] D
      such that D.prevalencePeriod starts during E.relevantPeriod) >= 2
  or exists(["Medication": "HEDIS; Diabetes Medication"] M
    where M.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 18
  and AgeInYearsAt(end of "Measurement Period") < 76
  and "Patient Has Diabetes"

define "Denominator Exclusion: Hospice"
  /*
   * config_link_id: exclusion_1
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
   where I.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
   where I.relevantPeriod overlaps "Denominator Period")

define "Numerator Performance Met":
  exists(["Laboratory Test, Performed": "Able; Fasting Glucose"] L
    where L.resultDateTime during "Measurement Period")
  and exists(["Assessment, Performed": "Able; Systolic Blood Pressure"] A
    where A.authorDateTime during "Measurement Period")
  and exists(["Assessment, Performed": "Able; Diastolic Blood Pressure"] A
    where A.authorDateTime during "Measurement Period")
  and exists(["Laboratory Test, Performed": "Able; Triglycerides"] L
    where L.resultDateTime during "Measurement Period")
  and exists(["Laboratory Test, Performed": "Able; HDL-C"] L
    where L.resultDateTime during "Measurement Period")
  and exists(["Assessment, Performed": "Able; Waist Circumference"] A
    where A.authorDateTime during "Measurement Period")

define "Numerator Performance Not Met":
  not "Denominator Exclusion: Hospice"
  and not "Numerator Performance Met"
