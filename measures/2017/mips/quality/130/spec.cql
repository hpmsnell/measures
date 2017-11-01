library MIPS_130_2017 version '1'

/*
 * Source: MIPS
 * ID: 130
 * Year: 2017
 * Version: 1
 */

using QDM

// Encounter, Performed

valueset "MIPS; MIPS 130 Encounter"

// Procedure, Performed

valueset "VSAC; Current Medications Documented SNMD": '2.16.840.1.113883.3.600.1.462'
valueset "MIPS; Performance Met: G8427"
valueset "MIPS; Denominator Exception: G8430"
valueset "MIPS; Performance Not Met; G8428"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter"
  ["Encounter, Performed": "MIPS; MIPS 130 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
    and AgeInYearsAt(start of "Measurement Period") >= 18
    and E.signingProvider.hasMeasureMembership = true

define "Valid Procedures"
  ["Procedure, Performed": "MIPS; Performance Met: G8427"]
  union ["Procedure, Performed": "VSAC; Current Medications Documented SNMD"]

define "Denominator":
  "Denominator Encounter"

define "Numerator Success: G8427":
  /*
   * config_link_id: G8427
   */
   "Valid Encounter" E //This is the encounter from the denominator
    with "Valid Procedures" P
      such that P.relevantPeriod begins E.relevantPeriod

define "Denominator Exception: G8430":
  /*
   * config_link_id: G8430
   */
  "Valid Encounter" E //This is the encounter from the denominator
    with ["Procedure, Performed": "MIPS; Denominator Exception: G8430"] P
      such that P.relevantPeriod begins E.relevantPeriod

define "Numerator Failure: G8428":
  /*
   * config_link_id: G8428
   */
  not "Denominator Exception: G8430"
  and not "Numerator Success: G8427"
