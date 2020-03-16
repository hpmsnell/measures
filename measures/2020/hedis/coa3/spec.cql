library HEDIS_COA3_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: COA3
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Functional Status Assessment": '2.16.840.1.113883.3.464.1004.1104'
valueset "HEDIS; Acute Inpatient POS"
valueset "HEDIS; Acute Inpatient"

// Able value sets

valueset "Able; Functional Status Assessment"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Functional Status Assessment":
  ["Procedure, Performed": "HEDIS; Functional Status Assessment"]
  union ["Procedure, Performed": "Able; Functional Status Assessment"]

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice Intervention"]
  union ["Encounter, Performed": "HEDIS; Hospice Encounter"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 66

define "Exclusion: Hospice":
  /*
   * config_link_id: exclusion_required_hospice
   */
   exists("Hospice" Hospice
     where Hospice.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Functional Status Assessment" FSA
    where FSA.relevantPeriod starts during "Measurement Period"
      and FSA.code.placeOfService in "HEDIS; Acute Inpatient POS"
    without ["Procedure, Performed": "HEDIS; Acute Inpatient"] Inpatient
      such that FSA.claimId = Inpatient.claimId)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
