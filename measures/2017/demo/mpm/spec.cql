library Demo_MPM_2017 version '1'

/*
 *
 * Source: Demo
 * ID: MPM
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Lab Panel"
valueset "NCQA Medication; CDC-L"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18
  and exists(["Medication": "HEDIS; CDC-L_2016"] M
    where M.relevantPeriod overlaps "Measurement Year")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Procedure, Performed": "HEDIS; Lab Panel"] P
    where P.relevantPeriod starts during "Measurement Year")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
