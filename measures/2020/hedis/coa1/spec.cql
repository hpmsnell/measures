library HEDIS_COA1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: COA1
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice Encounter": '2.16.840.1.113883.3.464.1004.1761'
valueset "HEDIS; Hospice Intervention": '2.16.840.1.113883.3.464.1004.1762'
valueset "HEDIS; Advance Care Planning": '2.16.840.1.113883.3.464.1004.1020'

// Able Value Sets

valueset "Able; Advance Directive"
valueset "Able; Advance Directive Discussed"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Advance Care Planning":
  ["Procedure, Performed": "HEDIS; Advance Care Planning"]
  union ["Diagnosis": "HEDIS; Advance Care Planning"]
  union ["Procedure, Performed": "Able; Advance Directive"]
  union ["Procedure, Performed": "Able; Advance Directive Discussed"]

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
  exists("Advance Care Planning" P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
