library MIPS_345_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 345
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 345 Procedure"
valueset "MIPS; Denominator Exclusion: 9006F"
valueset "MIPS; Denominator Exclusion: 9007F"
valueset "MIPS; Performance Not Met: G9257"
valueset "MIPS; Performance Not Met: G9256"
valueset "MIPS; Performance Met: G9259"

// VSAC value sets

valueset "VSAC; Ischemic Stroke": '2.16.840.1.113883.3.464.1003.104.12.1024'
valueset "VSAC; Hemorrhagic Stroke": '2.16.840.1.113883.3.117.1.7.1.212'

// Able value sets

valueset "Able; Death in Hospital"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 345 Procedure"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Stroke":
  ["Diagnosis": "VSAC; Ischemic Stroke"]
  union ["Diagnosis": "VSAC; Hemorrhagic Stroke"]

define "Stroke or Death":
  ["Procedure, Performed": "MIPS; Performance Not Met: G9257"]
  union ["Procedure, Performed": "MIPS; Performance Not Met: G9256"]
  union ["Diagnosis": "VSAC; Ischemic Stroke"]
  union ["Diagnosis": "VSAC; Hemorrhagic Stroke"]
  union ["Diagnosis": "Able; Death in Hospital"]

/* Populations */

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: 9006F":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: 9006F"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exclusion: 9007F":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: 9007F"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G9259":
  /*
   * config_link_id: G9259
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9259"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or not exists("Stroke or Death" P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod))

define "Numerator Performance Not Met: G9257":
  /*
   * config_link_id: G9257
   */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G9257"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Stroke" D
    with "Denominator Procedure" D
      such that D.prevalencePeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G9256":
  not "Denominator Exclusion: 9006F"
  and not "Denominator Exclusion: 9007F"
  and not "Numerator Performance Met: G9259"
  and not "Numerator Performance Not Met: G9257"
