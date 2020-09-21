library HEDIS_TRC3_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: TRC3
 * Year: 2019
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

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

define "Patient Engagement":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Procedure, Performed": "HEDIS; Transitional Care Management Services"]

/* Populations */

define "Denominator":
  exists "Qualifying Discharge"

define "Exclusion: Hospice":
	   /*
	   * config_link_id: exclusion_required_hospice
	   */
	   exists("Hospice During Period"("Measurement Period"))

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Patient Engagement" Engagement
    where Engagement.placeOfService != '81'
    with "Qualifying Discharge" Discharge
      such that Engagement.relevantPeriod starts during Interval [Discharge.dischargeDate, Discharge.dischargeDate + 30 days)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
