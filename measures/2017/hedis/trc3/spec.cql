library HEDIS_TRC4_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: TRC4
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Outpatient": ''
valueset "HEDIS; Telephone Visits": ''
valueset "HEDIS; Transitional Care Management Services": ''

// HEDIS value sets

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

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Patient Engagement":
  ["Encounter, Performed": "HEDIS; Outpatient"]
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Procedure, Performed": "HEDIS; Transitional Care Management Services"]

/* Populations */

define "Denominator":
  "Denominator Discharge"
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

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
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
