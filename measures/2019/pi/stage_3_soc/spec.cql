library MIPS_PI_HIE_1_2019 version '1'

/*
 * Source: MIPS
 * ID: PI_HIE_1
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using Able Health Data Model

parameter "Measurement Period" Interval<DateTime>
parameter "Reporting Provider ID" String

context Patient

define "Denominator Referral":
  ["Referral"] R
    where R.start_datetime during "Measurement Period"
      and R.provider_id = "Reporting Provider ID"

/* Populations */

define "Denominator":
  "Denominator Referral"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "Denominator Referral" R
    with ["System Event"] S1
      such that C1.start_datetime during "Measurement Period"
        and S1.type = "SUMMARY_OF_CARE_CREATION_AND_EXCHANGE"
        and S1.referral_id = R.external_id
    with ["System Event"] S2
      such that C2.start_datetime during "Measurement Period"
        and S2.type = "SUMMARY_OF_CARE_RECEIPT"
        and S2.referral_id = R.external_id

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
