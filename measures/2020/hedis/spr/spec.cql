library HEDIS_SPR_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: SPR
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
valueset "HEDIS; Acute Inpatient Stay":
valueset "HEDIS; COPD":
valueset "HEDIS; Emphysema":
valueset "HEDIS; Chronic Bronchitis":
valueset "HEDIS; Spirometry":

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]  

define "Encounter":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
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
    where E.relevantPeriod starts during [18 months before end of "Measurement Period", 6 months before end of "Measurement Period"]

define "COPD During Index Period Exists":
  exists("COPD During Index Period")

define "First COPD During Index Period":
  First("Encounter With COPD" E
    sort by E.relevantPeriod asc)

define "First COPD During Index Period Has Prior Diagnosis":
  exists("First COPD During Index Period" E1
    with "Encounter With COPD" E2
      such that E2.relevantPeriod starts 730 days or less before start of E1.relevantPeriod

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 40
  and not exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")
  and "COPD During Index Period Exists"
  and not "First COPD During Index Period Has Prior Diagnosis"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
   exists("First COPD During Index Period" E
     with ["Assessment, Performed": "HEDIS; Spirometry"] A
       such that A.authorDateTime during [730 days or less before start of E.relevantPeriod, 180 days afer start of E.relevantPeriod])


define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
