library MIPS_343_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 343
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 343 Procedure"
valueset "MIPS; Risk Factors for Colorectal Cancer"
valueset "MIPS; Performance Met: 3775F"
valueset "MIPS; Denominator Exception: G9496"
valueset "MIPS; Performance Not Met: 3776F"

// VSAC value sets

valueset "VSAC; Colon Cancer": 2.16.840.1.113883.3.526.3.391

// Able value sets

valueset "Able; Adenoma of Colon"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 343 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 50
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {52, 53, 73, 74}
    with ["Diagnosis": "MIPS; Risk Factors for Colorectal Cancer"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Adenoma of Colon":
  ["Diagnosis": "VSAC; Colon Cancer"]
  union ["Diagnosis": "Able; Adenoma of Colon"]

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: 3775F":
  /*
   * config_link_id: 3775F
   */
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "MIPS; Performance Met: 3775F"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)
  or exists("Denominator Procedure" P
   with "Adenoma of Colon" D
     such that D.prevalencePeriod starts during P.relevantPeriod)

define "Denominator Exception: G9496":
  /*
   * config_link_id: G9496
   */
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9496"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: 3776F":
  /*
   * config_link_id: 3776F
   */
  not "Numerator Performance Met: 3775F"
  and not "Denominator Exception: G9496"
