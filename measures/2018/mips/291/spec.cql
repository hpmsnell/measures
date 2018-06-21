library MIPS_291_2018 version '1'

/*
 * Source: MIPS
 * ID: 291
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 291 Encounter"
valueset "MIPS; Parkinson's Disease"
valueset "MIPS; Performance Met: 3720F"
valueset "MIPS; Performance Not Met: 3720F-8P"

// Able value sets

valueset "Able; Cognitive Assessment"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 291 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P.relevantPeriod) >= 18
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Parkinson's Disease"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 3720F":
  /*
   * config_link_id: 3720F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3720F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "Able; Cognitive Assessment"] P
   where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3720F-8P":
  /*
   * config_link_id: 3720F-8P
   */
  not "Numerator Performance Met: 3720F"
