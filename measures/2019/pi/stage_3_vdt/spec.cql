library STAGE_3_CMS_VDT_2019 version '1'

/*
 * Source: Stage 3
 * ID: VDT
 * Year: 2019
 * Version: 1
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
    where S.start_datetime during "Measurement Period"
      and S.type = "VDT_VIEW")
  or exists(["System Event"] S
    where S.start_datetime during "Measurement Period"
      and S.type = "VDT_DOWNLOAD")
  or exists(["System Event"] S
    where S.start_datetime during "Measurement Period"
      and S.type = "VDT_TRANSMISSION")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
