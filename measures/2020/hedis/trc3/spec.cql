library HEDIS_TRC4_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: TRC4
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Telephone Visits": '2.16.840.1.113883.3.464.1004.1246'
valueset "HEDIS; Transitional Care Management Services": '2.16.840.1.113883.3.464.1004.1462'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Discharge":
  ["Encounter, Performed": "HEDIS; Inpatient Stay"] Discharge
    where Discharge.supplemental = false

define "Qualifying Discharge":
  "Discharge" Discharge
    where Discharge.dischargeDate in Interval [start of "Measurement Period", end of "Measurement Period" - 30 days]
      and AgeInYearsAt(end of "Measurement Period") >= 18
    without "Discharge" Readmission
      such that Readmission.admissionDate starts on or 30 days or less after Discharge.dischargeDate
        and Discharge.claimId != Readmission.claimId

define "Hospice":
  (["Intervention, Performed": "HEDIS; Hospice Encounter"]
  union ["Intervention, Performed": "HEDIS; Hospice Intervention"])Hospice
    where Hospice.relevantPeriod overlaps "Measurement Period"

define "Patient Engagement":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Procedure, Performed": "HEDIS; Transitional Care Management Services"]

/* Populations */

define "Denominator":
  exists "Qualifying Discharge"

define "Denominator Exclusion: Hospice"
  /*
   * config_link_id: exclusion_required_hospice
   */
  exists "Hospice"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Patient Engagement" P
    with "Qualifying Discharge" E
      such that P.relevantPeriod starts 30 days or less after E.discharge_date)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
