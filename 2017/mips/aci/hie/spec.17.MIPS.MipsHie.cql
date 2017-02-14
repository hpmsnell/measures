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

// Able Value Sets

valueset "Able; Summary of Care"
valueset "Able; Transfer Document": '2.16.840.1.113883.1.11.20.2.4'

// VSAC Value Sets

valueset "VSAC; Referral": '2.16.840.1.113883.3.464.1003.101.12.1046'

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
