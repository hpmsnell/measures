library Demo_4B_2017 version '1'

/*
 *
 * Source: Demo
 * ID: 4B
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// Able value sets

valueset "Able; Chronic Disease Education"
valueset "Able; Patient Activation Measure"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "Able; Chronic Disease Education"] P
    where P.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
    with ["Assessment, Performed": "Able; Patient Activation Measure"] A
      where A.result < 47
      such that A.relevantPeriod starts during P.relevantPeriod

define "Denominator":
  exists("Denominator Procedure")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Assessment, Performed": "Able; Patient Activation Measure"] A
    where A.result >= 47
      and A.relevantPeriod starts during "Measurement Period"
    with "Denominator Procedure" P
      such that A.relevantPeriod starts 6 months or more after start of P.relevantPeriod)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
