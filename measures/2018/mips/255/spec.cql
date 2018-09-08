library RADNET_255_Rate_1_2018 version '1'

/*
 *
 * Source: RadNet
 * ID: 255
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// Custom value sets (MIPS)

valueset "MIPS; MIPS 255 Encounter"
valueset "MIPS; Rh-Negative"
valueset "MIPS; High Risk Pregnancy Complication"
valueset "MIPS; Performance Met: G8809"
valueset "MIPS; Denominator Exception: G8810"
valueset "MIPS; Performance Not Met: G8811"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 255 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 15
      and AgeInYearsAt(start of E.relevantPeriod) < 50
      and E.placeOfService = 23
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Rh-Negative"] D1
      such that D1.prevalencePeriod overlaps E.relevantPeriod
    with ["Diagnosis": "MIPS; High Risk Pregnancy Complication"] D1
      such that D1.prevalencePeriod overlaps E.relevantPeriod

// Populations

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G8809":
  // config_link_id: G8809
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8809"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G8809":
  // config_link_id: G8810
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G8810"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8811":
  // config_link_id: G8811
  not "Numerator Performance Met: G8809"
  and not "Denominator Exception: G8810"
