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
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; History of Kidney Transplant": '2.16.840.1.113883.3.464.1004.1908'
valueset "HEDIS; History of Malignant Neoplasm": '2.16.840.1.113883.3.464.1004.1121'
valueset "HEDIS; HIV": '2.16.840.1.113883.3.464.1004.1110'
valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Imaging Study": '2.16.840.1.113883.3.464.1004.1138'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; IV Drug Abuse": '2.16.840.1.113883.3.464.1004.1136'
valueset "HEDIS; Kidney Transplant": '2.16.840.1.113883.3.464.1004.1141'
valueset "HEDIS; Malignant Neoplasms": '2.16.840.1.113883.3.464.1004.1167'
valueset "HEDIS; Neurologic Impairment": '2.16.840.1.113883.3.464.1004.1185'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; Online Assessments": '2.16.840.1.113883.3.464.1004.1446'
valueset "HEDIS; Organ Transplant Other Than Kidney": '2.16.840.1.113883.3.464.1004.1195'
valueset "HEDIS; Osteopathic and Chiropractic Manipulative Treatment": '2.16.840.1.113883.3.464.1004.1196'
valueset "HEDIS; Other Malignant Neoplasm of Skin": '2.16.840.1.113883.3.464.1004.1463'
valueset "HEDIS; Other Neoplasms": '2.16.840.1.113883.3.464.1004.1201'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Physical Therapy": '2.16.840.1.113883.3.464.1004.1403'
valueset "HEDIS; Spinal Infection": '2.16.840.1.113883.3.464.1004.1404'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Trauma": '2.16.840.1.113883.3.464.1004.1254'
valueset "HEDIS; Uncomplicated Low Back Pain": '2.16.840.1.113883.3.464.1004.1422'


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
    without ["Encounter, Performed": "HEDIS; Inpatient Stay"] InptStay
  		such that E1.relevantPeriod ends 1 day or less before start of InptStay.relevantPeriod
  	without ["Encounter, Performed": "HEDIS; Inpatient Stay"] InptStay
  		such that InptStay.claimID = E1.claimID

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

define "Corticosteroid Start Date":
  "Corticosteroid in Past Year" M
    return end of M.relevantPeriod

define "Corticosteroid Days":
  "Corticosteroid in Past Year" M
    return days between start of M.relevantPeriod and end of M.relevantPeriod

define "Sum of Corticosteroid Days":
  Sum("Corticosteroid Days")

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
   or exists "Sum of Corticosteroid Days" >= 90 days

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
