library Demo_CDC4_2017 version '1'

/*
 *
 * Source: Demo
 * ID: CDC4
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Diabetic Retinal Screening"
valueset "HEDIS; Diabetes"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18
  and AgeInYearsAt(start of "Measurement Period") < 76
  and exists(["Diagnosis": "HEDIS; Diabetes"] D
    where D.prevalencePeriod overlaps "Measurement Year")


define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Procedure, Performed": "HEDIS; Diabetic Retinal Screening"] P
    where P.relevantPeriod starts during "Measurement Year")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
