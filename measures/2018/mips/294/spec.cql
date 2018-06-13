library MIPS_294_2017 version '1'

/*
 * Source: MIPS
 * ID: 294
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 294 Encounter"
valueset "MIPS; Parkinson's Disease"
valueset "MIPS; Performance Met: 4325F"
valueset "MIPS; Denominator Exception: 4325F-1P"
valueset "MIPS; Performance Not Met: 4325F-8P"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 294 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Parkinson's Disease"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

/* Populations */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 4325F":
  /*
   * config_link_id: 4325F
   */
  exists("Procedure, Performed": "MIPS; Performance Met: 4325F"] P
      where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 4325F-1P":
  /*
   * config_link_id: 4325F-1P
   */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: 4325F-1P"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: 4325F-8P":
  /*
   * config_link_id: 4325F-8P
   */
  not "Numerator Performance Met: 4325F"
  and not "Denominator Exception: 4325F-1P"
