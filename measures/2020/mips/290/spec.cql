library MIPS_290_2020 version '1'

/*
 * Source: MIPS
 * ID: 290
 * Year: 2020
 * Version: 1
 * Author: Patrick Clark
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 290 Encounter"
valueset "MIPS; Parkinson's Disease"
valueset "MIPS; Performance Met: G2121"
valueset "MIPS; Performance Not Met: G2122"

// Able value sets

valueset "Able; Psychiatric Assessment"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 290 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Parkinson's Disease"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Psychiatric Assessment":
  ["Procedure, Performed": "MIPS; Performance Met: G2121"]
  union ["Assessment, Performed": "Able; Psychiatric Assessment"]

/* Populations */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G2121":
  /*
   * config_link_id: G2121
   */
  exists("Psychiatric Assessment" P
    with "Denominator Encounter" E
      such that P.relaventPeriod starts on or 12 months or less before start of E.relevantPeriod

define "Numerator Performance Not Met: G2122":
  /*
   * config_link_id: G2122
   */
  not "Numerator Performance Met: G2121"
