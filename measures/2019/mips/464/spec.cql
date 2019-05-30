library MIPS_464_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 464
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 464 Encounter"
valueset "MIPS; OME"
valueset "MIPS; Performance Met: G9959"
valueset "MIPS; Denominator Exception: G9960"
valueset "MIPS; Performance Not Met: G9961"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 464 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInMonthsAt(start of E.relevantPeriod) >= 2
      and AgeInYearsAt(start of E.relevantPeriod) < 12
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in ['GQ', 'GT', '95']
      and not E.placeOfService = '02'
    with ["Diagnosis": "MIPS; OME"] D
      such that D.prevalencePeriod starts during E.relevantPeriod

define "G9959 Exists":
  exists(["Procedure, Performed": "MIPS; Performance Met: G9959"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 90 days or less after start of E.relevantPeriod)

define "G9960 Exists":
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9960"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 90 days or less after start of E.relevantPeriod)

define "G9961 Exists":
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G9961"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts on or 90 days or less after start of E.relevantPeriod)

define "Denominator":
  "Denominator Encounter" E1
    without "Denominator Encounter" E2
      such that E2.relevantPeriod starts 90 days or less before start of E1.relevantPeriod

define "Numerator Performance Met: G9959":
  /*
   * config_link_id: G9959
   */
  not "G9960 Exists"
  and not "G9961 Exists"
  and not exists(["Medication, Order": "VSAC; Systemic Antibiotics"] M
    with "Denominator Encounter" E
      such that M.relevantPeriod starts on or 90 days or less after start of E.relevantPeriod
        and M.signingProvider = M.signingProvider
  )

define "Denominator Exception: G9960":
  /*
   * config_link_id: G9960
   */
  "G9961 Exists"

define "Numerator Performance Not Met: G9961":
  /*
   * config_link_id: G9961
   */
  not "Numerator Performance Met: G9959"
  and not "Denominator Exception: G9960"
