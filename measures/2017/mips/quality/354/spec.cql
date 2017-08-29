library MIPS_354_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 354
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 354 Procedure"
valueset "MIPS; Performance Met: G9306"
valueset "MIPS; Performance Not Met: G9305"

// Able value sets

valueset "Able; Gastrointestinal Anastomotic Leakage"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 354 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Numerator Performance Met: G9306":
  /*
   * config_link_id: G9306
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9306"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 30 days or less after E.relevantPeriod)
  or exists(["Diagnosis": "Able; Gastrointestinal Anastomotic Leakage"] D
    with "Denominator Procedure" E
      such that D.prevalencePeriod starts 30 days or less after E.relevantPeriod)

define "Numerator Performance Not Met: G9305":
  /*
   * config_link_id: G9305
   */
  not "Numerator Performance Met: G9306"
