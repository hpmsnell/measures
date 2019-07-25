library STAGE_3_CPOE_MEDICATION_2019 version '1'

/*
 * Source: Stage 3
 * ID: CPOE_MEDICATION
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
      and M.provider_id = "Reporting Provider ID"

/* Populations */

define "Denominator":
  "Denominator Medication"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Denominator Medication" M
    where M.computerized_physician_order_entry = true

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
