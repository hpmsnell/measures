library MIPS_144_2017 version '1'

/*
 * Source: MIPS
 * ID: 144
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 144 Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Chemotherapy"
valueset "MIPS; Cancer"
valueset "MIPS; Performance Met: 0521F"
valueset "MIPS; Performance Not Met: 0521F-8P"

// Able value sets

valueset "Able; Pain Intervention"
valueset "Able; Opioids Used for Pain Control"
valueset "Able; Selected Non Opioids for Moderate to Severe Pain"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Pain Medication":
  ["Medication": "Able; Opioids Used for Pain Control"]
  union ["Medication": "Able; Selected Non Opioids for Moderate to Severe Pain"]

define "Denominator":
  "Measure 143: Numerator Performance Met: 1125F"

define "Numerator Performance Met: 0521F":
  /*
   * config_link_id: 0521F
   */
  "Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: 0521F"] P
      such that P.relevantPeriod starts during E.relevantPeriod
  or "Denominator Encounter" E
    with ["Procedure, Performed": "Able; Pain Intervention"] P
      such that P.relevantPeriod starts during E.relevantPeriod
  or "Denominator Encounter" E
    with "Pain Medication" M
      such that M.relevantPeriod overlaps E.relevantPeriod

define "Numerator Performance Not Met: 0521F-8P":
  /*
   * config_link_id: G8428
   */
  not "Numerator Performance Met: 0521F"
