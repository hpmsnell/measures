library MIPS_182_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 182
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 182 Encounter"
valueset "MIPS; Performance Met: G8542"
valueset "MIPS; Performance Met: G8539"
valueset "MIPS; Denominator Exception: G9227"
valueset "MIPS; Denominator Exception: G8540"
valueset "MIPS; Performance Not Met: G8543"
valueset "MIPS; Performance Not Met: G8541"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 182 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

// Populations

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G8542":
  // config_link_id: G8542
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8542"] P
      such that P.relevantPeriod starts on or 30 days or less after start of E.relevantPeriod)

define "Numerator Performance Met: G8539":
  // config_link_id: G8539
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8539"] P
      such that P.relevantPeriod starts on or 30 days or less after start of E.relevantPeriod)

define "Denominator Exception: G8540":
  // config_link_id: G8540
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G8540"] P
      such that P.relevantPeriod starts on or 30 days or less after start of E.relevantPeriod)

define "Denominator Exception: G9227":
  // config_link_id: G9227
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9227"] P
      such that P.relevantPeriod starts on or 30 days or less after start of E.relevantPeriod)

define "Numerator Performance Not Met: G8543":
  // config_link_id: G8543
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Not Met: G8543"] P
      such that P.relevantPeriod starts on or 30 days or less after start of E.relevantPeriod)

define "Numerator Performance Not Met: G8541":
  // config_link_id: G8541
  not "Numerator Performance Met: G8542"
  and not "Numerator Performance Met: G8539"
  and not "Denominator Exception: G8540"
  and not "Denominator Exception: G9227"
  and not "Numerator Performance Not Met: G8543"
