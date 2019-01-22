library MIPS_187_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 187
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 187 Encounter"
valueset "MIPS; MIPS 187 Ischemic Stroke"
valueset "MIPS; Last Known Well > 120 Minutes"
valueset "MIPS; Performance Met: G8600"
valueset "MIPS; Denominator Exception: G8601"
valueset "MIPS; Performance Not Met: G8602"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 187 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in ['GQ','GT']
      and not E.placeOfService = '02'
    with ["Diagnosis": "MIPS; MIPS 187 Ischemic Stroke"] D
      such that D.prevalencePeriod starts during E.relevantPeriod
    without ["Procedure, Performed": "MIPS; Last Known Well > 120 Minutes"] P
      such that P.relevantPeriod starts during E.relevantPeriod

// Populations

define "Denominator":
  "Denominator Encounter" E1
    without "Denominator Encounter" E2
      such that E2.relevantPeriod starts 1 day before start of E1.relevantPeriod

define "Numerator Performance Met: G8600":
  // config_link_id: G8600
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8600"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G8601":
  // config_link_id: G8600
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8600"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8602":
  // config_link_id: G8602\
  not "Numerator Performance Met: G8600"
  and not "Denominator Exception: G8601"
