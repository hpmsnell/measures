library HEDIS_LBP_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: LBP
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
valueset "HEDIS; Osteopathic and Chiropractic Manipulative Treatment"
valueset "HEDIS; Physical Therapy"
valueset "HEDIS; Telephone Visits"
valueset "HEDIS; Online Assessments"
valueset "HEDIS; Uncomplicated Low Back Pain"
valueset "HEDIS; Malignant Neoplasms"
valueset "HEDIS; Other Neoplasms"
valueset "HEDIS; History of Malignant Neoplasm"
valueset "HEDIS; HIV"
valueset "HEDIS; Organ Transplant Other Than Kidney"
valueset "HEDIS; Kidney Transplant"
valueset "HEDIS; Trauma"
valueset "HEDIS; IV Drug Abuse"
valueset "HEDIS; Neurologic Impairment"
valueset "HEDIS; Spinal Infection"
valueset "HEDIS; Imaging Study"

// NCQA medication list value sets

valueset "NCQA; Corticosteroids Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]


define "Encounter":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]
  union ["Encounter, Performed": "HEDIS; Osteopathic and Chiropractic Manipulative Treatment"]
  union ["Encounter, Performed": "HEDIS; Physical Therapy"]
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Encounter, Performed": "HEDIS; Online Assessments"]

define "Encounter With Low Back Pain":
  "Encounter" E1
    with ["Diagnosis": "HEDIS; Uncomplicated Low Back Pain"] D
      such that D.prevalencePeriod starts during E1.relevantPeriod
    without ["Encounter, Performed": "HEDIS; Inpatient Stay"] E2
      such that E2.relevantPeriod starts during E1.relevantPeriod

define "Low Back Pain During Index Period"
  "Encounter With Low Back Pain" E
    where E.relevantPeriod starts during [start of "Measurement Period", 28 days before end of "Measurement Period"]

define "Low Back Pain During Index Period Exists":
  exists("Low Back Pain During Index Period")

define "First Low Back Pain During Index Period":
  First("Encounter With Low Back Pain" E
    sort by E.relevantPeriod asc)

define "First Low Back Pain During Index Period Has Prior Diagnosis":
  exists("First Low Back Pain During Index Period" E1
    with "Encounter With Low Back Pain" E2
      such that E2.relevantPeriod starts 180 days or less before start of E1.relevantPeriod

define "Exclusion Anytime":
  ["Diagnosis": "HEDIS; Malignant Neoplasms"]
  union ["Diagnosis": "HEDIS; Other Neoplasms"]
  union ["Diagnosis": "HEDIS; History of Malignant Neoplasm"]
  union ["Diagnosis": "HEDIS; HIV"]
  union ["Diagnosis": "HEDIS; Organ Transplant Other Than Kidney"]
  union ["Diagnosis": "HEDIS; Kidney Transplant"]

define "Exclusion in Past Year":
  ["Diagnosis": "HEDIS; IV Drug Abuse"]
  union ["Diagnosis": "HEDIS; Neurologic Impairment"]
  union ["Diagnosis": "HEDIS; Spinal Infection"]

define "Corticosteroid":
  ["Medication, Dispensed": "NCQA; Corticosteroid Medications"]

define "Corticosteroid in Past Year":
  "Corticosteroid" M
    with "First Low Back Pain During Index Period" E
      such that M.relevantPeriod starts during [12 months days before start of E.relevantPeriod, start of E.relevantPeriod])

define "Corticosteroid Start Date":
  "Corticosteroid in Past Year" M
    return start of M.relevantPeriod

define "Corticosteroid Stop Date":
  "Corticosteroid in Past Year" M
    return end of M.relevantPeriod

define "Start of First Low Back Pain":
  "First Low Back Pain During Index Period" E
    return start of E.relevantPeriod

define "End of Corticosteroid Period":
  Floor("Corticosteroid Stop Date", "Start of First Low Back Pain")

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 19
  AgeInYearsAt(end of "Measurement Period") < 51
  and not exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")
  and "Low Back Pain During Index Period Exists"
  and not "First Low Back Pain During Index Period Has Prior Diagnosis"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
   exists("First Low Back Pain During Index Period" E
     with "Exclusion Anytime" A
       such that D.prevalencePeriod starts on or before 28 days after start of E.relevantPeriod)
   or exists("First Low Back Pain During Index Period" E
     with ["Diagnosis"; "HEDIS; Trauma"] D
       such that D.prevalencePeriod overlaps [3 months before start of E.relevantPeriod, 28 days after start of E.relevantPeriod])
   or exists("First Low Back Pain During Index Period" E
     with "Exclusion in Past Year" D
       such that D.prevalencePeriod overlaps [12 months days before start of E.relevantPeriod, 28 days after start of E.relevantPeriod])
   or "End of Corticosteroid Period" - "Corticosteroid Start Date" >= 90 days

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Assessment, Performed": "HEDIS; Imaging Study"] A
    with ["Diagnosis": "HEDIS; Uncomplicated Low Back Pain"] D
      such that D.prevalencePeriod starts at A.authorDateTime
    with "First Low Back Pain During Index Period" E
      such that A.authorDateTime during [start of E.relevantPeriod, 28 days afer start of E.relevantPeriod])


define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
