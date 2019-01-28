library MIPS_404_2018 version '1'

/*
 *
 * Source: MIPS
 * ID: 404
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 404 Procedure"
valueset "MIPS; MIPS 404 Smoker"
valueset "MIPS; MIPS 404 Elective Surgery"
valueset "MIPS; MIPS 404 Received Abstinence Instructions"
valueset "MIPS; Performance Met: G9644"
valueset "MIPS; Performance Not Met: G9645"

// VSAC value sets

valueset "VSAC; Tobacco User"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Smoker":
  ["Procedure, Performed": "MIPS; MIPS 404 Smoker"]
  union ["Assessment, Performed": "VSAC; Tobacco User"]

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 404 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
    with ["Procedure, Performed": "MIPS; MIPS 404 Elective Surgery"] P1
      such that P1.relevantPeriod starts during E.relevantPeriod
    with ["Procedure, Performed": "MIPS; MIPS 404 Received Abstinence Instructions"] P2
      such that P2.relevantPeriod starts during E.relevantPeriod
    with "Smoker" A
      such that A.authorDateTime on or 30 days or less before start of E.relevantPeriod

// Populations

define "Denominator":
  "Denominator Encounter"

define "Numerator Performance Met: G9644":
  // config_link_id: G9644
  exists("Denominator Encounter" E
    with ["Procedure, Performed": "MIPS; Performance Met: G9644"] P
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9645":
  // config_link_id: G9645
  not "Numerator Performance Met: G9644"
