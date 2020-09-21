library HEDIS_DDE_RATE_2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: DDE Rate 2
 * Year: 2020
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

valueset "NCQA; Dementia Medications": '2.16.840.1.113883.3.464.1004.1729'
valueset "NCQA; Potentially Harmful Drugs - Dementia Medications": '2.16.840.1.113883.3.464.1004.2169'
valueset "NCQA; Potentially Harmful Drugs - History of Falls and Dementia Medications": '2.16.840.1.113883.3.464.1004.2170'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Dementia":
  ["Diagnosis": "HEDIS; Dementia"]
  union ["Medication, Dispensed": "NCQA; Dementia Medications"]

define "Dementia During Index Period"
  "Dementia" D
    where D.prevalencePeriod starts during [24 months before end of "Measurement Period", 1 month before end of "Measurement Period"]

define "First Dementia During Index Period":
  First("Dementia During Index Period" D
    sort by D.prevalencePeriod asc)

define "Excluded Condition":
  ["Diagnosis": "HEDIS; Psychosis"]
  union ["Diagnosis": "HEDIS; Schizophrenia"]
  union ["Diagnosis": "HEDIS; Bipolar Disorder"]
  union ["Diagnosis": "HEDIS; Other Bipolar Disorder"]

define "Medication":
  ["Medication, Dispensed": "NCQA; Potentially Harmful Drugs - History of Falls and Dementia Medications"]
  union ["Medication, Dispensed": "NCQA; Potentially Harmful Drugs - History of Falls and Dementia Medications"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 67
  and exists("Dementia During Index Period")

define "Denominator Exclusion: Excluded Condition":
  /*
   * config_link_id: exclusion_1
   */
  exists("Excluded Diagnosis" D
    where D.prevalencePeriod overlaps [24 months before end of "Measurement Period", 1 month before end of "Measurement Period"]

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
   exists("First Dementia During Index Period" E // Since the end date is not achored to the first fall, any fall can be used
     with "Medication" A
       such that M.relevantPeriod starts during [start of E.relevantPeriod, end of "Measurement Period"])

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Excluded Condition"
  and not "Exclusion: Hospice"
  and not "Numerator Performance Met"
