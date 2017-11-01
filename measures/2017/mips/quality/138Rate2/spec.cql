library MIPS_138Rate2_2017 version '1'

/*
 * Source: MIPS
 * ID: 138 Rate 2
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 138 Excision of Malignant Melanoma"
valueset "MIPS; MIPS 138 Melanoma"
valueset "MIPS; Performance Met: 5050F"
valueset "MIPS; Denominator Exception: 5050F-2P"
valueset "MIPS; Denominator Exception: 5050F-3P"
valueset "MIPS; Performance Not Met: 5050F-8P"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Procedure, Performed": "MIPS; MIPS 138 Excision of Malignant Melanoma"] P
    where P.relevantPeriod starts during "Denominator Period"
      and P.signingProvider.pqrsProvider = true
    with ["Diagnosis": "MIPS; MIPS 138 Melanoma"] D
      such that D.prevalencePeriod during P.relevantPeriod

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: 5050F":
  /*
   * config_link_id: 5050F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 5050F"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denomninator Exception: 5050F-2P":
  /*
   * config_link_id: 5050F-2P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 5050F-2P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denomninator Exception: 5050F-3P":
  /*
   * config_link_id: 5050F-3P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 5050F-3P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: 5050F-8P":
  /*
   * config_link_id: 5050F-8P
   */
  not "Numerator Performance Met: 5050F"
  and not "Denomninator Exception: 5050F-2P"
  and not "Denomninator Exception: 5050F-3P"
