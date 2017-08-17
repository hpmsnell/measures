library MIPS_320_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 320
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 320 Encounter"
valueset "MIPS; Screening for Malignant Neoplasm of Colon"
valueset "MIPS; Performance Met: 0528F"
valueset "MIPS; Denominator Exception: 0528F-1P"
valueset "MIPS; Performance Not Met: 0528F-8P"

// VSAC value sets

valueset "VSAC; Colon Cancer": 2.16.840.1.113883.3.526.3.391

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 320 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 50
        and AgeInYearsAt(start of E.relevantPeriod) < 75
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {52, 53, 73, 74}
    with ["Diagnosis": "MIPS; Screening for Malignant Neoplasm of Colon"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 0528F":
  /*
   * config_link_id: 0528F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 0528F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 0528F-1P":
  /*
   * config_link_id: 0528F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 0528F-1P"] P
    where P.relevantPeriod starts during "Measurement Year")
  or exists(["Diagnosis": "VSAC; Colon Cancer"] D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Numerator Performance Not Met: 0528F-8P":
  /*
   * config_link_id: 0528F-8P
   */
  not "Numerator Performance Met: 0528F"
  and not "Denominator Exception: 0528F-1P"
