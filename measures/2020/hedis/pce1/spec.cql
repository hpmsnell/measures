library HEDIS_PCE1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: PCE1
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Acute Inpatient Stay":
valueset "HEDIS; COPD":
valueset "HEDIS; Emphysema":
valueset "HEDIS; Chronic Bronchitis":
valueset "HEDIS; Systemic Corticosteroid Medications":

valueset "VSAC; Corticosteroids": '2.16.840.1.113883.3.464.1003.196.12.1482'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Encounter":
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Inpatient Stay"]

define "COPD":
  ["Diagnosis": "HEDIS; COPD"]
  union ["Diagnosis": "HEDIS; Emphysema"]
  union ["Diagnosis": "HEDIS; Chronic Bronchitis"]

define "Encounter With COPD":
  "Encounter" E1
    with "COPD" D
      such that D.prevalencePeriod starts during E1.relevantPeriod
    without ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] E2
      such that E2.relevantPeriod starts during E1.relevantPeriod

define "COPD During Index Period"
  "Encounter With COPD" E
    where E.relevantPeriod starts during [start of "Measurement Period", 1 month before end of "Measurement Period"]
    and AgeInYearsAt(start of "Measurement Period") >= 40

define "Corticosteroid":
  ["Medication": "HEDIS; Systemic Corticosteroid Medications"]
  union ["Medication": "VSAC; Corticosteroids"]

/* Populations */

define "Denominator":
  "COPD During Index Period"
  and not exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "COPD During Index Period" E
    with "Corticosteroid" M
      such that M.relevantPeriod overlaps [start of E.relevantPeriod, 14 days after start of E.relevantPeriod]


define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
