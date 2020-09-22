library HEDIS_MRP_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: MRP
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

include "../shared/hedis_shared" version '1' called HedisShared

// HEDIS value sets

valueset "HEDIS; Nonacute Inpatient Stay": '2.16.840.1.113883.3.464.1004.1398'
valueset "HEDIS; Inpatient Stay": '2.16.840.1.113883.3.464.1004.1395'
valueset "HEDIS; Medication Reconciliation Encounter": '2.16.840.1.113883.3.464.1004.1528'
valueset "HEDIS; Medication Reconciliation Intervention": '2.16.840.1.113883.3.464.1004.1529'
valueset "HEDIS; CPT CAT II Modifier": '2.16.840.1.113883.3.464.1004.1464'

// Able value sets

valueset "Able; Medication Reconiliation"

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

define "Medication Reconciliation":
  ["Intervention, Performed": "HEDIS; Medication Reconciliation Intervention"]
  union ["Encounter, Performed": "HEDIS; Medication Reconciliation Encounter"]
  union ["Procedure, Performed": "Able; Medication Reconciliation"]


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
  exists "Medication Reconciliation" MedRec
    where MedRec.placeOfService != '81'
      and MedRec.code.modifiers not in "HEDIS; CPT CAT II Modifier")
    with "Qualifying Discharge" Discharge
      such that MedRec.relevantPeriod starts during Interval [Discharge.dischargeDate, Discharge.dischargeDate + 30 days)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
   not "Numerator Performance Met"
