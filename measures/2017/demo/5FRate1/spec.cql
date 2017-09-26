library Demo_5FRate1_2017 version '1'

/*
 *
 * Source: Demo
 * ID: 5F
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// Able value sets

valueset "Able; Discharge"
valueset "Able; Transitional Care Management"

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
  exists("Discharge" E
    with ["Procedure, Performed": "Able; Transitional Care Management"] P
      such that P.relevantPeriod starts 3 days or less after start of E.relevantPeriod)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
