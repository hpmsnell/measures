library MIPS_143_RATE_2_2019 version '1'

/*
 * Source: MIPS
 * ID: 143 Rate 2
 * Year: 2019
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 143 Procedure"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Cancer"
valueset "MIPS; Performance Met: 1125F"
valueset "MIPS; Performance Met: 1126F"
valueset "MIPS; Performance Not Met: 1125F-8P"

// VSAC value sets

valueset "VSAC; Standardized Pain Assessment Tool": '2.16.840.1.113883.3.526.3.1028'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 143 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with ["Diagnosis": "MIPS; Cancer"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: 1125F":
  /*
   * config_link_id: 1125F
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: 1125F"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod
  or "Denominator Procedure" E
    with ["Procedure, Performed": "VSAC; Standardized Pain Assessment Tool"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod
        and P.result > 0

define "Numerator Performance Met: 1126F":
  /*
   * config_link_id: 1126F
   */
   "Denominator Procedure" E
     with ["Procedure, Performed": "MIPS; Performance Met: 1126F"] P
       such that P.relevantPeriod starts during E.relevantPeriod
   or "Denominator Procedure" E
     with ["Procedure, Performed": "VSAC; Standardized Pain Assessment Tool"] P
       such that P.relevantPeriod starts during E.relevantPeriod
         and P.result = 0

define "Numerator Performance Not Met: 1125F-8P":
  /*
   * config_link_id: G8428
   */
  not "Numerator Performance Met: 1125F"
  and not "Numerator Performance Met: 1126F"
