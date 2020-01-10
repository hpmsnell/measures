library MIPS_AQI63_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: AQI63
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
valueset "MIPS; Performance Met: 11A19"
valueset "MIPS; Performance Not Met: 11A20"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS AQI63 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
    with ["Procedure, Performed": "MIPS; NMB"] P1
      such that P1.relevantPeriod starts during E.relevantPeriod
    with ["Procedure, Performed": "MIPS; Extubated Post-Operatively"] P2
      such that P2.relevantPeriod starts during E.relevantPeriod

// Populations

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: 11A17":
  // config_link_id: 11A17
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: 11A17"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: 11A20":
  // config_link_id: 11A20
  not "Numerator Performance Met: 11A17"
