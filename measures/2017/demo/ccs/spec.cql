library Demo_CCS_2017 version '1'

/*
 *
 * Source: Demo
 * ID: CCS
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Cervical Cytology"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 24
  and "Patient Characteristic Sex" = "Female"
  and AgeInYearsAt(start of "Measurement Period") < 75

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Laboratory Test, Performed": "HEDIS; Cervical Cytology"] L
    where L.resultDateTime 36 months or less before end of "Measurement Year")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
