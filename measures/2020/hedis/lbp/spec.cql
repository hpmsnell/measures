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

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; History of Kidney Transplant": '2.16.840.1.113883.3.464.1004.1908'
valueset "HEDIS; History of Malignant Neoplasm": '2.16.840.1.113883.3.464.1004.1121'
valueset "HEDIS; HIV": '2.16.840.1.113883.3.464.1004.1110'
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

define "Encounter Set1":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Observation"]
  union ["Encounter, Performed": "HEDIS; ED"]

define "Encounter Set2":
  ["Encounter, Performed": "HEDIS; Osteopathic and Chiropractic Manipulative Treatment"]
  union ["Encounter, Performed": "HEDIS; Physical Therapy"]
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Encounter, Performed": "HEDIS; Online Assessments"]

define "Encounter With Low Back Pain":
  "Encounter Set1" E1
    where exists (E1.diagnoses D
      where D.code in "HEDIS; Uncomplicated Low Back Pain"
      and D.rank = 1)
    without ["Encounter, Performed": "HEDIS; Inpatient Stay"] InptStay
  		such that E1.relevantPeriod ends 1 day or less before start of InptStay.relevantPeriod
  	without ["Encounter, Performed": "HEDIS; Inpatient Stay"] InptStay
  		such that InptStay.claimID = E1.claimID
  union  "Encounter Set2" E1
    where exists (E1.diagnoses D
      where D.code in "HEDIS; Uncomplicated Low Back Pain"
      and D.rank = 1)

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
      such that E2.relevantPeriod starts 180 days or less before start of E1.relevantPeriod)

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
      such that M.relevantPeriod starts during [12 months days before start of E.relevantPeriod, start of E.relevantPeriod]

define "Index Period Stop Date":
  "First Low Back Pain During Index Period" E
    return start of E.relevantPeriod

// Individual corticosteroid case

define "Prescription Start Date":
  "Corticosteroid in Past Year" M
    return start of M.relevantPeriod

define "Prescription Stop Date":
  "Corticosteroid in Past Year" M
    return end of M.relevantPeriod

define "Prescription Duration":
  Min(
    {
      days between "Prescription Start Date" and "Prescription Stop Date",
      days between "Prescription Start Date" and "Index Period Stop Date" // Default to this if Stop Date is null
    }
  )

// Multiple overlapping corticosteroid case

define "Overlapping Prescription":
  "Corticosteroid in Past Year" M1
    with "Corticosteroid in Past Year" M2
      such that M1.relevantPeriod overlaps M2.relevantPeriod
    sort by start of M1.relevantPeriod

define "Overlapping Prescription Start Date":
  "Overlapping Prescription" M
    return start of M.relevantPeriod

define "Overlapping Prescription Stop Date":
  "Overlapping Prescription" M
    return end of M.relevantPeriod

define "Sum of Overlapping Presription Durations":
  Sum(days between "Overlapping Prescription Start Date" and "Overlapping Prescription Stop Date")

define "First Overlapping Prescription Start Date":
  First("Overlapping Prescription") M
    return start of M.relevantPeriod

define "Sum of Overlappiong Prescription Durations Within Index Period":
  Min(
    {
      Sum("Overlapping Prescription Duration"),
      days between  "First Overlapping Prescription Start Date" and "Index Period Stop Date"
    }
  )


/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 19
  AgeInYearsAt(end of "Measurement Period") < 51
  and "Low Back Pain During Index Period Exists"
  and not "First Low Back Pain During Index Period Has Prior Diagnosis"

define "Exclusion: Hospice":
   /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice During Period"("Measurement Period"))

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
    or "Prescription Duration" >= 90 days
    or "Sum of Overlapping Prescription Durations Within Index Period" >= 90 days

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
  not "Exclusion: Hospice"
  and not "Denominator Exclusion"
  and not "Numerator Performance Met"
