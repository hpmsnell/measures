library MIPS_401_2018 version '1'

/*
 * Source: MIPS
 * ID: 401
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 401 Encounter"
valueset "MIPS; Chronic Hepatitis C"
valueset "MIPS; Performance Met: G9455"
valueset "MIPS; Denominator Exception: G9456"
valueset "MIPS; Performance Not Met: G9457"

// Able value value sets

valueset "Able; Imaging for Hepatocellular Carcinoma"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 401 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; HIV/AIDS"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

/* POPULATIONS */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G9455":
  /*
   * config_link_id: G9455
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9455"] P
    where P.relevantPeriod starts during "Measurement Period"
  or exists(["Procedure, Performed": "Able; Imaging for Hepatocellula Carcinoma"] P
    where P.relevantPeriod starts during "Measurement Period"

define "Denominator Exception: G9456":
  /*
   * config_link_id: G9456
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9456"] P
    where P.relevantPeriod starts during "Measurement Period"

define "Numerator Performance Not Met: G9457":
 /*
  * config_link_id: G9457
  */
 not "Numerator Performance Met: G9455"
 and not "Denominator Exception: G9456"
