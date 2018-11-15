library MIPS_426_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 426
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 426 Encounter"
valueset "MIPS; Transfer to PACU or Other Non-ICU"
valueset "MIPS; Performance Met: G9655"
valueset "MIPS; Performance Not Met: G9658"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 426 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
    with ["Procedure, Performed": "MIPS; Transfer to PACU or Other Non-ICU"] P
      such that P.relevantPeriod starts during E.relevantPeriod

// Populations

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G9655":
  // config_link_id: G9655
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9655"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9658":
  // config_link_id: G9658
  not "Numerator Performance Met: G9655"
