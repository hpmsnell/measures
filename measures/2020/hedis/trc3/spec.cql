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

// Able value sets

valueset "Able; Able Discharge"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Discharge":
  ["Encounter, Performed": "HEDIS; Inpatient Stay"]
  union ["Encounter, Performed": "Able; Able Discharge"]

define "Denominator Discharge":
   "Discharge" E1
    where E1.relevantPeriod starts during [start of "Measurement Period", 30 days before end of "Measurement Period"]
    and AgeInYearsAt(end of "Measurement Period") >= 18
    without "Discharge" E2
      such that E2.relevantPeriod starts 30 days or less after start of E1.relevantPeriod

define "Acute in Nonacute":
  ((["Encounter, Performed": "HEDIS; Inpatient Stay"])InpatientStay
    with ("HEDIS; Nonacute Inpatient Stay")NonacuteIPStay
    such that InpatientStay.relevantPeriod during NonacuteIPStay.relevantPeriod

define "Hospice":
  (["Intervention, Performed": "HEDIS; Hospice Encounter"]
  union ["Intervention, Performed": "HEDIS; Hospice Intervention"])HospiceEnc
    where HospiceEnc.relevantPeriod overlaps "Measurement Period"

define "Patient Engagement":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Procedure, Performed": "HEDIS; Transitional Care Management Services"]

/* Populations */

define "Denominator":
  exists "Denominator Discharge"
  and not exists "Hospice"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Patient Engagement" P
    with "Discharge" E
      such that P.relevantPeriod starts 30 days or less after end of E.relevantPeriod)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
