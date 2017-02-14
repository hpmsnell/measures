library MIPS_HIE_2017 version '1'

/*
 * Source: MIPS
 * ID: HIE
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By: Rachel Katz
 *
  */

using QDM

// MIPS Value Sets

valueset "Able; Transition of Care or Referral"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  exists(["Intervention, Performed": "Able; Transition of Care or Referral"] I
    where I.relevantPeriod starts during "Measurement Period")
      and I.signingProvider.pqrsProvider = 1

define "Numerator":
  /*
   * config_link_id: numerator
   */
  exists(["Intervention, Performed": "Able; Transition of Care or Referral"] I
    where I.authorDateTime during "Measurement Period")
    with ["Procedure, Performed": "Able; Transition of Care"] P
    such that P.relevantPeriod starts during I.relevantPeriod
