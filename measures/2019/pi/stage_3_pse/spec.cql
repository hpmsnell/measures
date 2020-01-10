library STAGE_3_PSE_2019 version '1'

/*
 * Source: Stage 3
 * ID: PSE
 * Year: 2019
 * Version: 2
 * Author: Steve Daniels
 *
  */

using Able Health Data Model

parameter "Measurement Period" Interval<DateTime>
parameter "Reporting Provider ID" String

context Patient

/* Populations */

define "Denominator":
  exists(["Encounter"] E
    where E.start_datetime during "Measurement Period"
      and E.provider_id = "Reporting Provider ID")

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["System Event"] S
    where S.start_datetime same year as start of "Measurement Period"
      and S.code_value = "EDUCATION_PROVISION"
      and S.provider_id = "Reporting Provider ID")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
