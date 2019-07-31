library HEDIS_AWV2_2019 version '1'

/*
 *
 * Source: Able
 * ID: AWV2
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// Able Value Sets

valueset "Able; Annual Wellness Visit - Medicare"

parameter "Measurement Period" Interval<DateTime>

context Patient

/* Populations */

define "Denominator":

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Encounter, Performed": "Able; Annual Wellness Visit - Commercial/Medicaid"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
