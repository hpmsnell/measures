library Demo_CDC10_2017 version '1'

/*
 *
 * Source: Demo
 * ID: CDC10
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Diabetes"

// VSAC value sets

valueset "VSAC; HbA1c Laboratory Test": '2.16.840.1.113883.3.464.1003.198.12.1013'

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
  Last(["Laboratory Test, Performed": "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Year").result <= 8

define "Numerator Performance Not Met: Bad Result":
  /*
   * config_link_id: bad_result
   */
  Last(["Laboratory Test, Performed": "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Year").result > 8

define "Numerator Performance Not Met: No Result":
  /*
   * config_link_id: no_result
   */
  not "Numerator Performance Met"
