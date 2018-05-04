library MIPS_091_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 091
 * Year: 2018
 * Version: 1
 * Author: Becky Weber
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 091 Encounter"
valueset "MIPS; Acute Otitis Externa (AOE)"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Performance Met: 4130F"
valueset "MIPS; Denominator Exception: 4130F-1P"
valueset "MIPS; Denominator Exception: 4130F-2P"
valueset "MIPS; Performance Not Met: 4130F-8P"

// Able value sets

valueset "Able; Topical Antibiotic for AOE"
valueset "Able; Acute Otitis Media"
valueset "Able; Tympanic Membrane Perforation"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "AOE":
  ["Diagnosis": "MIPS; Acute Otitis Externa (AOE)"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 091 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 2
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"
    with "AOE" D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "Coexisting Diagnosis":
  ["Diagnosis": "Able; Tympanic Membrane Perforation"]
  union ["Diagnosis": "Able; Acute Otitis Media"]

define "Denominator":
  "Denominator Encounter" E1
    without "Denominator Encounter" E2
      such that E1.relevantPeriod starts 30 days or less after E2.relevantPeriod

define "Numerator Performance Met: 4130F":
  /*
   * config_link_id: 4130F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4130F"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
  or exists(["Medication": "Able; Topical Antibiotic for AOEs"] M
    with "Denominator Encounter" E
      such that M.relevantPeriod overlaps E.relevantPeriod]

define "Denominator Exception: 4130F-1P":
  /*
   * config_link_id: 4130F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4130F-1P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
  or exists("Coexisting Conditions" D
    with "Denominator Encounter" E
      such that D.relevantPeriod overlaps E.relevantPeriod)

define "Denominator Exception: 4130F-2P":
  /*
   * config_link_id: 4130F-2P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4130F-2P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: 4130F-8P":
  /*
   * config_link_id: 4130F-8P
   */
  not "Numerator Performance Met: 4130F"
  and not "Denominator Exception: 4130F-1P"
  and not "Denominator Exception: 4130F-2P"
