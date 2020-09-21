library HEDIS_DDE_RATE_3_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: DDE Rate 3
 * Year: 2019
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1810'
valueset "HEDIS; Bipolar Disorder": '2.16.840.1.113883.3.464.1004.1044'
valueset "HEDIS; CKD Stage 4": '2.16.840.1.113883.3.464.1004.1052'
valueset "HEDIS; Dementia": '2.16.840.1.113883.3.464.1004.1074'
valueset "HEDIS; Dialysis Procedure": '2.16.840.1.113883.3.464.1004.1952'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; ESRD Diagnosis": '2.16.840.1.113883.3.464.1004.1747'
valueset "HEDIS; Falls": '2.16.840.1.113883.3.464.1004.1101'
valueset "HEDIS; Hip Fractures": '2.16.840.1.113883.3.464.1004.1264'
valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Kidney Transplant": '2.16.840.1.113883.3.464.1004.1141'
valueset "HEDIS; Major Depression or Dysthymia": '2.16.840.1.113883.3.464.1004.1351'
valueset "HEDIS; Nephrectomy": '2.16.840.1.113883.3.464.1004.1909'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; Other Bipolar Disorder": '2.16.840.1.113883.3.464.1004.1399'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Psychosis": '2.16.840.1.113883.3.464.1004.1227'
valueset "HEDIS; Schizophrenia": '2.16.840.1.113883.3.464.1004.1234'
valueset "HEDIS; Seizure Disorders": '2.16.840.1.113883.3.464.1004.1235'

// NCQA medication list value sets

valueset "NCQA; Cox-2 Selective NSAIDs and Nonaspirin NSAIDs Medications": '2.16.840.1.113883.3.464.1004.1733'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Kidney Disease":
  ["Diagnosis": "HEDIS; CKD Stage 4"]
  union ["Diagnosis": "HEDIS; ESRD Diagnosis"]
  union ["Procedure, Performed": "HEDIS; ESRD Diagnosis"]
  union ["Diagnosis": "HEDIS; Nephrectomy"]
  union ["Procedure, Performed": "HEDIS; Nephrectomy"]
  union ["Diagnosis": "HEDIS; Kidney Transplant"]
  union ["Procedure, Performed": "HEDIS; Kidney Transplant"]
  union ["Diagnosis": "HEDIS; Dialysis Procedure"]
  union ["Procedure, Performed": "HEDIS; Dialysis Procedure"]

define "Kidney Disease During Index Period"
  "Kidney Disease" D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", 1 month before end of "Measurement Period"]

define "First Kidney Disease During Index Period":
  First("Kidney Disease During Index Period" D
    sort by D.prevalencePeriod asc)

define "Medication":
  ["Medication, Dispensed": "NCQA; Cox-2 Selective NSAIDs and Nonaspirin NSAIDs Medications"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 67
  and exists("Kidney Disease During Index Period")

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
   exists("First Kidney Disease During Index Period" E // Since the end date is not achored to the first fall, any fall can be used
     with "Medication" A
       such that M.relevantPeriod starts during [start of E.relevantPeriod, end of "Measurement Period"])

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Exclusion: Hospice"
  and not "Numerator Performance Met"
