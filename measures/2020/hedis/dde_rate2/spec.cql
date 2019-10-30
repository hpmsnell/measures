library HEDIS_DDE_RATE_2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: DDE Rate 2
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Dementia"
valueset "HEDIS; Dementia Medications"
valueset "HEDIS; Psychosis"
valueset "HEDIS; Schizophrenia"
valueset "HEDIS; Bipolar Disorder"
valueset "HEDIS; Other Bipolar Disorder"
valueset "HEDIS; Potentially Harmful Drugs—Rate 2 Medications"
valueset "HEDIS; Potentially Harmful Drugs—Rate 1 and Rate 2 Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]  

define "Dementia":
  ["Diagnosis": "HEDIS; Hip Dementia"]
  union ["Medication, Dispensed": "HEDIS; Dementia Medications"]

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
  ["Medication, Dispensed": "HEDIS; Potentially Harmful Drugs—Rate 2 Medications"]
  union ["Medication, Dispensed": "HEDIS; Potentially Harmful Drugs—Rate 1 and Rate 2 Medications"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 67
  and not exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")
  and exists("Dementia During Index Period")

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
   exists("First Dementia During Index Period" E // Since the end date is not achored to the first fall, any fall can be used
     with "Medication" A
       such that M.relevantPeriod starts during [start of E.relevantPeriod, end of "Measurement Period"])

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion: Excluded Condition"
  and not "Numerator Performance Met"
