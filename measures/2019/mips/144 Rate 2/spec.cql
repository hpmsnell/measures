library MIPS_144_RATE_2_2019 version '1'

/*
 * Source: MIPS
 * ID: 144 Rate 2
 * Year: 2019
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 144 Procedure"
valueset "MIPS; Cancer"
valueset "MIPS; Moderate to Severe Pain"
valueset "MIPS; Performance Met: M1001"
valueset "MIPS; Performance Not Met: M1002"

// VSAC value sets

valueset "VSAC; Standardized Pain Assessment Tool": '2.16.840.1.113883.3.526.3.1028'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 144 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with ["Diagnosis": "MIPS; Cancer"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

/* Populations */

define "Denominator":
  "Denominator Procedure" E
     with ["Procedure, Performed": "MIPS; Moderate to Severe Pain"] P
       such that P.relevantPeriod starts same day as start of E.relevantPeriod
  or "Denominator Procedure" E
    with ["Procedure, Performed": "VSAC; Standardized Pain Assessment Tool"] P
      such that P.relevantPeriod starts same day as start of E.relevantPeriod
        and P.result >= 4

define "Numerator Performance Met: M1001":
  /*
   * config_link_id: M1001
   */
  "Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: M1001"] P
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: M1002":
  /*
   * config_link_id: M1002
   */
  not "Numerator Performance Met: M1001"
