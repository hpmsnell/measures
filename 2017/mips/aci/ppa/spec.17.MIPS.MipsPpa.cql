library MIPS_PPA_2017 version '1'

/*
 * Source: MIPS
 * ID: PPA
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// Able Value Sets

valueset "Able; ACI Encounter"
valueset "Able; Patient Portal Notification"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":

  exists(["Intervention, Performed": "Able; Referral"] I
    where I.relevantPeriod starts during "Measurement Period")
      and I.signingProvider.pqrsProvider = 1

define "Summary of Care":
  ["Procedure, Performed": "Able; Summary of Care"]
  union ["Procedure, Performed": "VSAC; TransferDocumentType"]

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists(["Intervention, Performed": "Able; Referral"] I
    where I.authorDateTime during "Measurement Period")
    with  "Summary of Care" P
      such that P.relevantPeriod starts during I.relevantPeriod

define "Numerator Performance Not Met"
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
