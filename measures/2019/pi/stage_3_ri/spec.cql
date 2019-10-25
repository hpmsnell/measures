library STAGE_3_RI_2019 version '8'

/*
 * Source: Stage 3
 * ID: RI
 * Year: 2019
 * Version: 8
 * Author: Steve Daniels
 *
  */

using Able Health Data Model

parameter "Measurement Period" Interval<DateTime>
parameter "Reporting Provider ID" String

context Patient

define "Denominator Encounter with Summary of Care":
  ["Encounter"] E
    where E.start_datetime during "Measurement Period"
      and R.provider_id = "Reporting Provider ID"
    with ["Clinical Document"] C
      such that C.type = "INBOUND_SUMMARY_OF_CARE"
        and C.start_datetime before E.stop_datetime
        and C.encounter_id = E.external_id
  union ["Encounter"] E
    where E.start_datetime during "Measurement Period"
      and R.provider_id = "Reporting Provider ID"
    with ["System Event"] S
      such that S.type = "OUTSIDE_SUMMARY_OF_CARE_AVAILABLE"
        and S.start_datetime during [E.start_datetime, end of "Measurement Period"]
        and S.encounter_id = E.external_id

define "Denominator Transfer of Care":
  "Denominator Encounter with Summary of Care" E
    with ["Clinical Activity": "Able; New Encounter"] C
      such that C.relevantPeriod starts during "Measurement Period"
        and C.encounter_id = E.encounter_id
  union "Denominator Encounter with Summary of Care" E
    with ["System Event"] S
      such that S.start_datetime during "Measurement Period"
        and S.type = "INBOUND_TRANSITION_OF_CARE"
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
      such that S1.start_datetime same year as start of "Measurment Period"
        and S1.start_datetime on or after E.start_datetime
        and S.start_datetime on or after E.start_datetime
        and S.type in ["SUMMARY_OF_CARE_INCORPORATION","SUMMARY_OF_CARE_INCORPORATION_STAGE_3"]
        and S.encounter_id = E.external_id

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
