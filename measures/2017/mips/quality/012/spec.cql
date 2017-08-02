library MIPS_012_2017 version '1'

/*
 * Source: MIPS
 * ID: 012
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Custom Value Sets

valueset "MIPS; MIPS 012 Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Primary Open-Angle Glaucoma (POAG)"
valueset "MIPS; Performance Met: 2027F"
valueset "MIPS; Denominator Exception: 2027F-1P"
valueset "MIPS; Performance Not Met: 2027F-8P"

// Able Value Sets

valueset "Able; Optic Nerve Head Evaluation"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 012 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in "MIPS; Telehealth Modifier"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Primary Open-Angle Glaucoma (POAG)"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 2027F":
  /*
   * config_link_id: 2027F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 2027F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Assessment, Performed": "Able; Optic Nerve Head Evaluation"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 2027F-1P":
  /*
   * config_link_id: 2027F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 2027F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 2027F-8P":
  /*
   * config_link_id: 2027F-8P
   */
  and "Numerator Performance Met: 2027F"
  and not "Denominator Exception: 2027F-1P"
