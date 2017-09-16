library MIPS_141_2017 version '1'

/*
 * Source: MIPS
 * ID: 141
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Custom Value Sets

valueset "MIPS; MIPS 141 Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG)"
valueset "MIPS; Performance Met: 3284F"
valueset "MIPS; Performance Met: 3285F"
valueset "MIPS; Performance Met: 0517F"
valueset "MIPS; Performance Not Met: 0517F-8P"
valueset "MIPS; Performance Not Met: 3284F-8P"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 141 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'GQ', 'GT'}
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG)"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 3284F":
  /*
   * config_link_id: 3284F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3284F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 3285F/0517F":
  /*
   * config_link_id: 3285F-0517F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3285F"] P
    where P.relevantPeriod starts during "Measurement Period")
  exists(["Procedure, Performed": "MIPS; Performance Met: 0517F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3285F/0517F-8P":
  /*
   * config_link_id: 3285F-0517F-8P
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3285F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3284F-8P":
  /*
   * config_link_id: 3284F-8P
   */
  "Numerator Performance Met: 3284F"
  and "Numerator Performance Met: 3285F/0517F"
  and "Numerator Performance Not Met: 3285F/0517F-8P"
