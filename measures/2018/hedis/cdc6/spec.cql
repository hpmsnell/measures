library HEDIS_CDC6_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC6
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
valueset "HEDIS; Urine Protein Tests": '2.16.840.1.113883.3.464.1004.1400'
valueset "HEDIS; Nephropathy Treatment": '2.16.840.1.113883.3.464.1004.1184'
valueset "HEDIS; CKD Stage 4": '2.16.840.1.113883.3.464.1004.1052'
valueset "HEDIS; ESRD": '2.16.840.1.113883.3.464.1004.1089'
valueset "HEDIS; Kidney Transplant": '2.16.840.1.113883.3.464.1004.1141'
valueset "HEDIS; Diabetes Medications"
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; ACE Inhibitor or ARB": '2.16.840.1.113883.3.526.3.1139'

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

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

define "Denominator Exclusion: Hospice"
  /*
   * config_link_id: exclusion_1
   */
  "HEDIS CDC1: Denominator Exclusion: Hospice"

define "Denominator Exclusion: Diagnosis"
  /*
  * config_link_id: exclusion_2
  */
  "HEDIS CDC1: Denominator Exclusion: Diagnosis"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Laboratory Test, Performed": "HEDIS; Urine Protein Tests"] L
    where L.resultDateTime during "Measurement Year")
  or exists("Nephropathy Procedures" P
    where P.relevantPeriod starts during "Measurement Year")
  or exists("Nephropathy Diagnoses" D
    where D.prevalencePeriod starts during "Measurement Year")
  or exists(["Medication": "VSAC; ACE Inhibitor or ARB"] M
    where M.relevantPeriod starts during "Measurement Year")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
