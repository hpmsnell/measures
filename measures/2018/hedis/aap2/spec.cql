library HEDIS_AAP2_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: AAP2
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS Value Sets

valueset "HEDIS; Ambulatory Visits"
valueset "HEDIS; Other Ambulatory Visits"
valueset "HEDIS; Telephone Visits"
valueset "HEDIS; Online Assessments"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Visit":
  ["Encounter, Performed": "HEDIS; Ambulatory Visits"]
  union ["Encounter, Performed": "HEDIS; Other Ambulatory Visits"]
  union ["Encounter, Performed": "HEDIS; Telephone Visits"]
  union ["Encounter, Performed": "HEDIS; Online Assessments"]

/* Populations */

define "Denominator":
  AgeInYearsAt(end of "Meaurement Period") >= 20

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
