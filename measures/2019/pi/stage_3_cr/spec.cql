library STAGE_3_CR_2019 version '8'

/*
 * Source: MIPS
 * ID: CR
 * Year: 2019
 * Version: 8
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
      and E.provider_id = "Reporting Provider ID"

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
  union "Denominator Encounter" E
    with ["Clinical Document"] C
      such that C.start_datetime before E.stop_datetime
        and C.type = "INBOUND_SUMMARY_OF_CARE"
        and C.encounter_id = E.external_id

/* Populations */

define "Denominator":
  "Denominator Transfer of Care"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Denominator Transfer of Care" E
    with ["System Event"] S1
      such that S1.start_datetime same year as "Measurement Period"
        and S1.start_datetime on or after E.start_datetime
        and S.type in ["MEDICATION_LIST_RECONCILIATION","MEDICATION_LIST_RECONCILIATION_STAGE_3"]
        and S1.encounter_id = E.external_id
    with ["System Event"] S2
      such that S2.start_datetime same year as "Measurement Period"
        and S2.start_datetime on or after E.start_datetime
        and S.type in ["ALLERGY_LIST_RECONCILIATION","ALLERGY_LIST_RECONCILIATION_STAGE_3"]
        and S2.encounter_id = E.external_id
    with ["System Event"] S3
      such that S3.start_datetime same year as "Measurement Period"
        and S3.start_datetime on or after E.start_datetime
        and S.type in ["PROBLEM_LIST_RECONCILIATION","PROBLEM_LIST_RECONCILIATION_STAGE_3"]
        and S3.encounter_id = E.external_id

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
