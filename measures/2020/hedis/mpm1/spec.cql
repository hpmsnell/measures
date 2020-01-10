library HEDIS_MPM1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: MPM1
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Lab Panel": '2.16.840.1.113883.3.464.1004.1145'
valueset "HEDIS; Serum Potassium": '2.16.840.1.113883.3.464.1004.1237'
valueset "HEDIS; Serum Creatinine": '2.16.840.1.113883.3.464.1004.1236'

// NCQA medication list value sets

valueset "NCQA; ACE Inhibitor/ARB Medications"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Medication Exists for At Least 180 Days":
  Sum("Medication Duration") >= 180

define "Medication Duration":
  duration in days of ["Medication Period Start Date","Medication Period End Date"]

define "Medication Period Start Date":
  Last(
    {
      "Medication Start Date",
      start of "Measurement Period"
    }
    sort asc
  )

define "Medication Period End Date":
  First(
    {
      "Medication End Date",
      end of "Measurement Period"
    }
    sort asc
  )

define "Medication Start Date":
  "Medication" M
    return start of M.relevantPeriod

define "Medication End Date":
  "Medication" M
    return end of M.relevantPeriod

define "Medication":
  ["Medication, Dispensed": "NCQA; ACE Inhibitor/ARB Medications"] M
    where M.relevantPeriod overlaps "Measurement Period"

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Inpatient Encounter"
  ["Encounter, Performed": "HEDIS; Acute Inpatient Visit"]
  union ["Encounter, Performed": "HEDIS; Nonacute Inpatient Visit"]

define "Serum Potassium Test":
  ["Assessment, Performed": "HEDIS; Serum Potassium"]
  union ["Laboratory Test, Performed": "HEDIS; Serum Potassium"]

define "Serum Creatinine Test":
  ["Assessment, Performed": "HEDIS; Serum Creatinine"]
  union ["Laboratory Test, Performed": "HEDIS; Serum Creatinine"]

define "Serum Potassium and Creatinine Tests Exist":
  exists("Serum Potassium Test" A
    where A.authorDateTime during "Measurement Period")
  and exists("Serum Creatinine Test" A
    where A.authorDateTime during "Measurement Period")

/* Populations */

define "Denominator":
  "Medication Exists for At Least 180 Days"
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists("Inpatient Encounter" E
    where E.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Assessment, Performed": "HEDIS; Lab Panel"] A
    where A.authorDateTime during "Measurement Period")
  or "Serum Potassium and Creatinine Tests Exist"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
