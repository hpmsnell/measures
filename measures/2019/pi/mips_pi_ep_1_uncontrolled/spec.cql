library MIPS_PI_EP_1_UNCONTROLLED_2019 version '1'

/*
 * Source: MIPS
 * ID: PI_EP_1
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using Able Health Data Model

parameter "Measurement Period" Interval<DateTime>
parameter "Reporting Provider ID" String

context Patient

define "Denominator Medication":
  ["Medication"] M
    where M.start_datetime during "Measurement Period"
      and M.prescribed = true
      and M.controlled_substance = false
      and M.provider_id = "Reporting Provider ID"

/* Populations */

define "Denominator":
  "Denominator Medication"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Denominator Medication" M
    where M.prescription_method = "electronic"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
