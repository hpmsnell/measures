library HEDIS_PCE2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: PCE2
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Chronic Bronchitis": '2.16.840.1.113883.3.464.1004.1061'
valueset "HEDIS; COPD": '2.16.840.1.113883.3.464.1004.1053'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Emphysema": '2.16.840.1.113883.3.464.1004.1091'
valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'

// NCQA medication list value sets

valueset "NCQA; Bronchodialtor Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "Hospice Intervention"]
  union ["Encounter, Performed": "Hospice Encounter"]

define "Encounter":
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Inpatient Stay"]

define "COPD":
  ["Diagnosis": "HEDIS; COPD"]
  union ["Diagnosis": "HEDIS; Emphysema"]
  union ["Diagnosis": "HEDIS; Chronic Bronchitis"]

define "Encounter With COPD":
  "Encounter" E1
    where exists (E1.diagnoses D Where D.code in "COPD" )
      without ["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"] E2
        such that E2.relevantPeriod starts during E1.relevantPeriod

define "COPD During Index Period"
  "Encounter With COPD" E
    where E.relevantPeriod starts during [start of "Measurement Period", 1 month before end of "Measurement Period"]
    and AgeInYearsAt(start of "Measurement Period") >= 40

define "Bronchodilator":
  ["Medication, Dispensed": "NCQA; Bronchodialtor Medications"]

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
    with "Bronchodilator" M
      such that M.relevantPeriod overlaps [start of E.relevantPeriod, 30 days after start of E.relevantPeriod]


define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
