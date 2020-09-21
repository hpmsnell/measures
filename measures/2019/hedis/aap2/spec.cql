library HEDIS_AAP2_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: AAP2
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS Value Sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Ambulatory Visits"
valueset "HEDIS; Other Ambulatory Visits"
valueset "HEDIS; Telephone Visits"
valueset "HEDIS; Online Assessments"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Visit":
  ["Encounter, Performed": "HEDIS; Ambulatory Visits"]
  union ["Encounter, Performed": "HEDIS; Other Ambulatory Visits"]
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Encounter, Performed": "HEDIS; Online Assessments"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Meaurement Period") >= 20
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Visit" E
    where E.relevantPeriod starts during [2 years before start of "Measurement Period", end of "Measurement Period"])

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
