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

context Patient

define "Valid Encounter"
  ["Encounter, Performed": "MIPS; MIPS 130 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
    and AgeInYearsAt(start of "Measurement Period") >= 18
    and E.signingProvider.pqrsProvider = true

define "Valid Procedures"
  ["Procedure, Performed": "MIPS; Performance Met: G8427"]
  union ["Procedure, Performed": "VSAC; Current Medications Documented SNMD"]

define "Denominator":
  "Valid Encounter"

define "Denominator Exclusion: G8430":
  /*
   * metadata_identifier_link: G8430
   */
  "Valid Encounter" E //This is the encounter from the denominator
    with ["Procedure, Performed": "MIPS; Denominator Exception: G8430"] P
      such that P.relevantPeriod begins E.relevantPeriod
      and P.signingProvider.id = E.signingProvider.id

define "Numerator Success: G8427":
  /*
   * metadata_identifier_link: G8427
   */
  "Denominator"
  and not "Denominator Exclusions"
  and "Valid Encounter" E //This is the encounter from the denominator
    with "Valid Procedures" P
      such that P.relevantPeriod begins E.relevantPeriod
      and P.signingProvider.id = E.signingProvider.id

define "Numerator Failure: G8428":
  /*
   * metadata_identifier_link: G8428
   */
  "Denominator"
  and not "Denominator Exclusion: G8430"
  and not "Numerator Success: G8427"
