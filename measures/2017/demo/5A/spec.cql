library Demo_5A_2017 version '1'

/*
 *
 * Source: Demo
 * ID: 5A
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// VSAC value sets

valueset "VSAC; Hospital Inpatient Visit - Subsequent": '2.16.840.1.113883.3.464.1003.101.11.1025'

// Able value sets

valueset "Able; Discharge"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Discharge":
  ["Encounter, Performed": "Able; Discharge"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Discharge"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Discharge" E1
    with ["Encounter, Performed": "VSAC; Hospital Inpatient Visit - Subsequent"] E2
      such that E2.relevantPeriod starts 30 days or less after start of E1.relevantPeriod)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
