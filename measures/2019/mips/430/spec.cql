library MIPS_430_2019 version '1'

/*
 *
 * Source: MIPS
 * ID: 430
 * Rate: 1
 * Year: 2019
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 430 Procedure"
valueset "MIPS; MIPS 430 Inhalational Anesthetic Agent"
valueset "MIPS; MIPS 430 3 Risk Factors for PONV"
valueset "MIPS; Performance Met: G9775"
valueset "MIPS; Denominator Exception: G9776"
valueset "MIPS; Performance Not Met: G9777"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 430 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
    with ["Procedure, Performed": "MIPS; MIPS 430 Inhalational Anesthetic Agent"] P1
      such that P1.relevantPeriod starts during E.relevantPeriod
    with ["Procedure, Performed": "MIPS; MIPS 430 3 Risk Factors for PONV"] P2
      such that P2.relevantPeriod starts during E.relevantPeriod

// Populations

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G9775":
  // config_link_id: G9775
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9775"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G9776":
  // config_link_id: G9776
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Denominator Exception: G9776"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9777":
  // config_link_id: G9777
  not "Numerator Performance Met: G9775"
  and not "Denominator Exception: G9776"
