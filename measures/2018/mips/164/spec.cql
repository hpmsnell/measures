library MIPS_164_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 164
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 164 Procedure"
valueset "MIPS; Performance Met: G8569"
valueset "MIPS; Performance Not Met: G8570"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 164 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true

// Populations

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G8569":
  // config_link_id: G8569
  exists("Denominator Procedure" E
    with ["Procedure, Performed": "MIPS; Performance Met: G8569"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G8570":
  // config_link_id: G8570
  not "Numerator Performance Met: G8569"
