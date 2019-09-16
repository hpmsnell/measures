library MIPS_AQI64_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: AQI64
 * Rate: 1
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS AQI63 Encounter"
valueset "MIPS; NMB"
valueset "MIPS; Extubated Post-Operatively"
valueset "MIPS; Denominator Exclusion: 11A21"
valueset "MIPS; Performance Met: 11A22"
valueset "MIPS; Performance Met: 11A23"
valueset "MIPS; Performance Met: 11A24"
valueset "MIPS; Performance Not Met: 11A25"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS AQI63 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) => 12
      and E.signingProvider.hasMeasureMembership = true
    with ["Procedure, Performed": "MIPS; NMB"] P1
      such that P1.relevantPeriod starts during E.relevantPeriod
    with ["Procedure, Performed": "MIPS; Extubated Post-Operatively"] P2
      such that P2.relevantPeriod starts during E.relevantPeriod

// Populations

define "Denominator":
  "Denominator Encounter"

define "Denominator Exclusion: 11A21":
  // config_link_id: 11A21
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exclusion: 11A21"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: 11A22":
  // config_link_id: 11A22
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: 11A22"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: 11A23":
  // config_link_id: 11A23
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: 11A23"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: 11A24":
  // config_link_id: 11A24
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: 11A24"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: 11A25":
  // config_link_id: 11A25
  not "Numerator Performance Met: 11A22"
