library HEDIS_DDE_RATE_1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: DDE Rate 1
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Falls"
valueset "HEDIS; Hip Fractures"
valueset "HEDIS; Psychosis"
valueset "HEDIS; Schizophrenia"
valueset "HEDIS; Bipolar Disorder"
valueset "HEDIS; Other Bipolar Disorder"
valueset "HEDIS; Seizure Disorders"
valueset "HEDIS; Potentially Harmful Drugs—Rate 1 Medications"
valueset "HEDIS; Potentially Harmful Drugs—Rate 1 and Rate 2 Medications"


parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]  

define "Encounter":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Inpatient Stay"]

define "Fracture":
  ["Diagnosis": "HEDIS; Hip Fractures"]
  union ["Procedure, Performed": "HEDIS; Hip Fractures"]

define "Fall or Encounter with Fall":
  ["Diagnosis": "HEDIS; Falls"]
  union "Encounter" E
    with "Fracture" D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Fall During Index Period"
  "Fall or Encounter with Fall" E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", 1 month before end of "Measurement Period"]

define "First Fall During Index Period":
  First("Fall During Index Period" E
    sort by E.relevantPeriod asc)

define "Excluded Condition":
  ["Diagnosis": "HEDIS; Psychosis"]
  union ["Diagnosis": "HEDIS; Schizophrenia"]
  union ["Diagnosis": "HEDIS; Bipolar Disorder"]
  union ["Diagnosis": "HEDIS; Other Bipolar Disorder"]
  union ["Diagnosis": "HEDIS; Seizure Disorders"]

define "Medication":
  ["Medication, Dispensed": "HEDIS; Potentially Harmful Drugs—Rate 1 Medications"]
  union ["Medication, Dispensed": "HEDIS; Potentially Harmful Drugs—Rate 1 and Rate 2 Medications"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 67
  and not exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")
  and exists("Fall During Index Period")

define "Denominator Exclusion: Excluded Condition":
  /*
   * config_link_id: exclusion_1
   */
  exists("Excluded Diagnosis" D
    where D.prevalencePeriod overlaps [24 months before end of "Measurement Period", 1 month before end of "Measurement Period"]

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
   exists("First Fall During Index Period" E // Since the end date is not achored to the first fall, any fall can be used
     with "Medication" A
       such that M.relevantPeriod starts during [start of E.relevantPeriod, end of "Measurement Period"])

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Excluded Condition"
  and not "Numerator Performance Met"
