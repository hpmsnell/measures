library MIPS_138Rate3_2018 version '1'

/*
 * Source: MIPS
 * ID: 138 Rate 3
 * Year: 2018
 * Version: 2
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 138 Encounter"
valueset "MIPS; MIPS 138 Melanoma"
valueset "MIPS; Performance Met: 5050F"
valueset "MIPS; Denominator Exception: 5050F-2P"
valueset "MIPS; Denominator Exception: 5050F-3P"
valueset "MIPS; Performance Not Met: 5050F-8P"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 138 Encounter"] E
    where E.relevantPeriod starts during [start of "Measurement Period", 3 months before end of "Measurement Period"]
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with ["Diagnosis": "MIPS; MIPS 138 Melanoma"] D
      such that D.prevalencePeriod during E.relevantPeriod

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
