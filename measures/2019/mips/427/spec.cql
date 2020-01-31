library MIPS_427_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 427
 * Rate: 1
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 427 Procedure"
valueset "MIPS; MIPS 427 Transferred Directly to CCU"
valueset "MIPS; Performance Met: 0583F"
valueset "MIPS; Performance Not Met: 0583F-8P"

parameter "Measurement Period" Interval<DateTime>

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 427 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'51', '80'}
    with ["Procedure, Performed": "MIPS; MIPS 427 Transferred Directly to CCU"] P1
      such that P1.relevantPeriod starts during E.relevantPeriod

// Populations

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: 0583F":
  // config_link_id: 0583F
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: 0583F"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: 0583F-8P":
  // config_link_id: 0583F-8P
  not "Numerator Performance Met: 0583F"
