library STAGE_3_CONTROLLED_2020 version '1'

/*
 * Source: MIPS
 * ID: PI_EP_1
 * Year: 2020
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
      and M.provider_id = "Reporting Provider ID"

/* Populations */

define "Denominator":
  "Denominator Medication"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Denominator Medication" M
    where M.sent_datetime during "Measurement Period"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
