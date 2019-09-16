library MIPS_PI_HIE_4_2019 version '1'

/*
 * Source: MIPS
 * ID: PI_HIE_4
 * Year: 2019
 * Version: 4
 * Author: Steve Daniels
 *
  */

using Able Health Data Model

parameter "Measurement Period" Interval<DateTime>
parameter "Reporting Provider ID" String

context Patient

define "Denominator Encounter":
  ["Encounter"] E
    where E.start_datetime during "Measurement Period"
      and R.provider_id = "Reporting Provider ID"
    with ["System Event"] S
      such that S.start_datetime during [2 years before E.start_datetime, E.start_datetime]
        and S.type = "INBOUND_SUMMARY_OF_CARE"
        and S.encounter_id = E.external_id

define "Denominator Transfer of Care":
  "Denominator Encounter" E
    with ["Clinical Activity": "Able; New Encounter"] C
      such that C.relevantPeriod starts during "Measurement Period"
        and C.encounter_id = E.encounter_id
  union "Denominator Encounter" E
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
    with ["System Event"] S1
      such that S1.start_datetime same year as start of "Measurment Period"
        and S1.start_datetime on or after E.start_datetime
        and S1.type = "SUMMARY_OF_CARE_INCORPORATION"
        and S1.encounter_id = E.external_id
    with ["System Event"] S2
      such that S2.start_datetime same year as start of "Measurment Period"
        and S2.start_datetime on or after E.start_datetime
        and S2.type = "MEDICATION_LIST_RECONCILIATION"
        and S2.encounter_id = E.external_id
    with ["System Event"] S3
      such that S3.start_datetime same year as start of "Measurment Period"
        and S3.start_datetime on or after E.start_datetime
        and S3.type = "ALLERGY_LIST_RECONCILIATION"
        and S3.encounter_id = E.external_id
    with ["System Event"] S4
      such that S4.start_datetime same year as start of "Measurment Period"
        and S4.start_datetime on or after E.start_datetime
        and S4.type = "PROBLEM_LIST_RECONCILIATION"
        and S4.encounter_id = E.external_id

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
