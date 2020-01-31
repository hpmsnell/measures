library MIPS_424_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 424
 * Rate: 1
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 424 Procedure"
valueset "MIPS; MIPS 424 Anesthesia 60 Minutes"
valueset "MIPS; Denominator Exclusion: G9654"
valueset "MIPS; Denominator Exclusion: G9770"
valueset "MIPS; Performance Met: G9771"
valueset "MIPS; Denominator Exception: G9772"
valueset "MIPS; Performance Not Met: G9773"

parameter "Measurement Period" Interval<DateTime>

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 424 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'51', '80'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Procedure, Performed": "MIPS; MIPS 424 Anesthesia 60 Minutes"] P1
      such that P1.relevantPeriod starts during E.relevantPeriod

// Populations

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion: G9654":
  // config_link_id: G9654
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exclusion: G9654"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exclusion: G9770":
  // config_link_id: G9771
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exclusion: G9770"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G9771":
  // config_link_id: G9771
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9771"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G9772":
  // config_link_id: G9772
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9772"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9773":
  // config_link_id: G9773
  not "Denominator Exclusion: G9654"
  and not "Denominator Exclusion: G9770"
  and not "Numerator Performance Met: G9771"
  and not "Denominator Exception: G9772"
