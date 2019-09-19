library STAGE_3_RI_2019 version '1'

/*
 * Source: Stage 3
 * ID: RI
 * Year: 2019
 * Version: 4
 * Author: Steve Daniels
 *
  */

using Able Health Data Model

parameter "Measurement Period" Interval<DateTime>
parameter "Reporting Provider ID" String

context Patient

define "Summary of Care":
  ["System Event"] S
    where S.type = "INBOUND_SUMMARY_OF_CARE"
  union ["System Event"] S
    where S.type = "OUTSIDE_SUMMARY_OF_CARE_AVAILABLE"

define "Denominator Encounter":
  ["Encounter"] E
    where E.start_datetime during "Measurement Period"
      and R.provider_id = "Reporting Provider ID"
    with "Summary of Care"
      such that S.start_datetime on or before E.stop_datetime
        and S.encounter_id = E.external_id

define "Denominator Transfer of Care":
  "Denominator Encounter" E
    with ["Clinical Activity": "Able; New Encounter"] C
      such that C.relevantPeriod starts during "Measurement Period"
        and C.encounter_id = E.encounter_id
  union "Denominator Encounter" E
    with "Summary of Care"
      such that S.start_datetime on or before E.stop_datetime
        and S.encounter_id = E.external_id

/* Populations */

define "Denominator":
  "Denominator Transfer of Care"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Denominator Transfer of Care" E
    with ["System Event"] S
      such that S.start_datetime during [E.start_datetime, end of "Measurement Period"]
        and S.start_datetime on or after E.start_datetime
        and S.type = "SUMMARY_OF_CARE_INCORPORATION"
        and S.encounter_id = E.external_id

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
