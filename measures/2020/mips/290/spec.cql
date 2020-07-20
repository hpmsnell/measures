library MIPS_290_2018 version '1'

/*
 * Source: MIPS
 * ID: 290
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 290 Encounter"
valueset "MIPS; Parkinson's Disease"
valueset "MIPS; Performance Met: G9742"
valueset "MIPS; Performance Not Met: G9743"

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
  ["Procedure, Performed": "MIPS; Performance Met: G9742"]
  union ["Assessment, Performed": "Able; Psychiatric Assessment"]

/* Populations */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G9742":
  /*
   * config_link_id: G9742
   */
  exists("Psychiatric Assessment" P
    with "Denominator Encounter" E
      such that P.relaventPeriod starts on or 12 months or less before start of E.relevantPeriod

define "Numerator Performance Not Met: G9743":
  /*
   * config_link_id: G9743
   */
  not "Numerator Performance Met: G9742"
