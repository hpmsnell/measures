library STAGE_3_CPOE_LAB_2019 version '1'

/*
 * Source: Stage 3
 * ID: CPOE_LAB
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using Able Health Data Model

parameter "Measurement Period" Interval<DateTime>
parameter "Reporting Provider ID" String

context Patient

define "Denominator Lab Order":
  ["Order"] O
    where O.start_datetime during "Measurement Period"
      and O.code_type = "CPT"
      and O.code_value >= 80000
      and O.code_value < 90000
      and O.provider_id = "Reporting Provider ID"

/* Populations */

define "Denominator":
  "Denominator Lab Order"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Denominator Lab Order" O
    where O.computerized_physician_order_entry = true

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
