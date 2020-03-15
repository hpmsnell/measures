library HEDIS_TRC4_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: TRC4
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Medication Reconciliation Encounter": '2.16.840.1.113883.3.464.1004.1528'
valueset "HEDIS; Medication Reconciliation Intervention": '2.16.840.1.113883.3.464.1004.1529'

// Able value sets

valueset "Able; Medication Reconiliation": ''
valueset "Able; Able Discharge"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Discharge":
  ["Encounter, Performed": "HEDIS; Inpatient Stay"]
  union ["Encounter, Performed": "Able; Able Discharge"]
  union "Nonacute Overlaps"

define "Qualifying Discharge":
  "Discharge" E1
    where E1.relevantPeriod starts during [start of "Measurement Period", 30 days before end of "Measurement Period"]
      and AgeInYearsAt(end of "Measurement Period") >= 18
    without "Discharge" E2
      such that E2.relevantPeriod starts 30 days or less after start of E1.relevantPeriod

define "Nonacute Overlaps":
  ((["Encounter, Performed": "HEDIS; Inpatient Stay"])InpatientStay
    with (["Encounter, Performed": "HEDIS; Nonacute Inpatient Stay"])NonacuteIPStay
    such that InpatientStay.relevantPeriod during NonacuteIPStay.relevantPeriod)

define "Hospice":
  (["Intervention, Performed": "HEDIS; Hospice Intervention"]
  union ["Encounter, Performed": "HEDIS; Hospice Encounter"])Hospice
    where Hospice.relevantPeriod overlaps "Measurement Period"

define "Medication Reconciliation":
  ["Intervention, Performed": "HEDIS; Medication Reconciliation Intervention"]
  union ["Encounter, Performed": "HEDIS; Medication Reconciliation Encounter"]
  union ["Procedure, Performed": "Able; Medication Reconciliation"]


/* Populations */

define "Denominator":
  exists "Qualifying Discharge"
  and not exists "Hospice"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists "Medication Reconciliation" P
    with "Qualifying Discharge" E
      such that P.relevantPeriod during Interval[end of E.relevantPeriod, end of E.relevantPeriod + 31 days)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
   not "Numerator Performance Met"
