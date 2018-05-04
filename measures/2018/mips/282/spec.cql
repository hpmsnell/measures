library MIPS_282_2017 version '1'

/*
 * Source: MIPS
 * ID: 282
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// Able Custom Value Sets

valueset "MIPS; MIPS 282 Encounter"
valueset "MIPS; Dementia"
valueset "MIPS; Performance Met: G9916"
valueset "MIPS; Denominator Exception: G9917"
valueset "MIPS; Performance Not Met: G9918"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// Able Value Sets

valueset "Able; Functional Status Assessment"
valueset "Able; Activities of Daily Living Assessment"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 282 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifer in {'QG', 'GT', '95'}
      and not E.placeOfServices in {'02'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Dementia"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Functional Status Assessment":
  ["Procedure, Performed": "MIPS; Performance Met: G9916"]
  union ["Assessment, Performed": "Able; Functional Status Assessment"]
  union ["Assessment, Performed": "Able; Activities of Daily Living Assessment"]

/* Populations */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G9916":
  /*
   * config_link_id: G9916
   */
  exists("Denominator Encounter" E
    with "Functional Status Assessment" P
      such that P.relevantPeriod starts on or 1 year or less before start of E.relevantPeriod)

define "Denominator Exception: G9917":
  /*
   * config_link_id: G9917
   */
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9917"] P
      such that P.relevantPeriod starts on or 1 year or less before start of E.relevantPeriod)

define "Numerator Performance Not Met: G9918":
  /*
   * config_link_id: G9918
   */
  not "Numerator Performance Met: G9916"
  and not "Denominator Exception: G9917"
