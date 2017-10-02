library MIPS_143_2017 version '1'

/*
 * Source: MIPS
 * ID: 143
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 143 Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Chemotherapy"
valueset "MIPS; Cancer"
valueset "MIPS; Performance Met: 1125F"
valueset "MIPS; Performance Met: 1126F"
valueset "MIPS; Performance Not Met: 1125F-8P"

// VSAC value sets

valueset "VSAC; Standardized Pain Assessment Tool": '2.16.840.1.113883.3.526.3.1028'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 143 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"
    with ["Diagnosis": "MIPS; Cancer"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod
    with ["Procedure, Performed": "MIPS; Chemotherapy"] P
      such that P.relevantPeriod starts on or between 30 days before and 30 days after start of E.relevantPeriod

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: 1125F":
  /*
   * config_link_id: 1125F
   */
  "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: 1125F"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod
  or "Denominator Encounter" E
    with ["Procedure, Performed": "VSAC; Standardized Pain Assessment Tool"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod
        and P.result > 0

define "Numerator Performance Met: 1126F":
  /*
   * config_link_id: 1126F
   */
   "Denominator Encounter" E
     with ["Procedure, Performed": "MIPS; Performance Met: 1126F"] P
       such that P.relevantPeriod starts during E.relevantPeriod
   or "Denominator Encounter" E
     with ["Procedure, Performed": "VSAC; Standardized Pain Assessment Tool"] P
       such that P.relevantPeriod starts during E.relevantPeriod
         and P.result = 0

define "Numerator Performance Not Met: 1125F-8P":
  /*
   * config_link_id: G8428
   */
  not "Numerator Performance Met: 1125F"
  and not "Numerator Performance Met: 1126F"
