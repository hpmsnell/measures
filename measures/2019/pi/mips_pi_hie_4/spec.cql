library MIPS_PI_HIE_4_2019 version '9'

/*
 * Source: MIPS
 * ID: PI_HIE_4
 * Year: 2019
 * Version: 9
 * Author: Steve Daniels
 *
  */

using Able Health Data Model

parameter "Measurement Period" Interval<DateTime>
parameter "Reporting Provider ID" String

context Patient

define "Transition of Care":
  ["Clinical Activity": "Able; New Encounter"]
  union ["System Event"] S
    where S.type = "INBOUND_TRANSITION_OF_CARE"

define "Denominator Summary of Care":
  ["ClinicalDocument"] C
    where C.type = "INBOUND_SUMMARY_OF_CARE"
      C.provider_id = "Reporting Provider ID"
    with ["Encounter"] E
      such that E.relevantPeriod starts during "Measurement Period"
        and C.start_datetime before E.stop_datetime
        and C.encounter_id = E.external_id
    with "Transition of Care" TOC
      such that TOC.start_datetime during "Measurement Period"
        and TOC.encounter_id = E.encounter_id

/* Populations */

define "Denominator":
  "Denominator Summary of Care"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Denominator Summary of Care" C
    with ["System Event"] S1
      such that S1.start_datetime during [C.start_datetime, end of "Measurement Period"]
        and S1.type in ["SUMMARY_OF_CARE_INCORPORATION","SUMMARY_OF_CARE_INCORPORATION_MIPS"]
        and S1.clinical_document_id = C.external_id
    with ["System Event"] S2
      such that S2.start_datetime during [C.start_datetime, end of "Measurement Period"]
        and S2.type in ["MEDICATION_LIST_RECONCILIATION","MEDICATION_LIST_RECONCILIATION_MIPS"]
        and S2.clinical_document_id = C.external_id
    with ["System Event"] S3
      such that S3.start_datetime during [C.start_datetime, end of "Measurement Period"]
        and S3.type in ["ALLERGY_LIST_RECONCILIATION","ALLERGY_LIST_RECONCILIATION_MIPS"]
        and S3.clinical_document_id = C.external_id
    with ["System Event"] S4
      such that S4.start_datetime during [C.start_datetime, end of "Measurement Period"]
        and S4.type in ["PROBLEM_LIST_RECONCILIATION","PROBLEM_LIST_RECONCILIATION_MIPS"]
        and S4.clinical_document_id = C.external_id

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
