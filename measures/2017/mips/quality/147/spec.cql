library MIPS_147_2017 version '1'

/*
 * Source: MIPS
 * ID: 147
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 147 Encounter"
valueset "MIPS; Performance Met: 3570F"
valueset "MIPS; Performance Met: 3570F-3P"
valueset "MIPS; Performance Not Met: 3570F-8P"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 147 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: 3570F":
  /*
   * config_link_id: 3570F
   */
  "Denominator Encounter" E
    with ["Encounter, Performed": "MIPS; Performance Met: 3570F"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod

define "Denominator Exception: 3570F-3P":
  /*
   * config_link_id: 3570F-3P
   */
   "Denominator Encounter" E
     with ["Encounter, Performed": "MIPS; Denominator Exception: 3570F-3P"] P
       such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 3570F-8P":
  /*
   * config_link_id: 3570F-8P
   */
  not "Numerator Performance Met: 3570F"
  and not "Denominator Exception: 3570F-3P"
