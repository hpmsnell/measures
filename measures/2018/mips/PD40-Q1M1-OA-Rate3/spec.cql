library RADNET_PD40-Q1M1-OA_Rate_3_2018 version '1'

/*
 *
 * Source: RadNet
 * ID: PD40-Q1M1-OA
 * Rate: 3
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// Custom value sets (Able)

valueset "Able; RadNet PD10-Q1M1-OA Procedure"
valueset "Able; Performance Met: GPD40N2A"
valueset "Able; RadNet Patient Exclusion"
valueset "Able; Performance Met: GPD40N3A"
valueset "Able; Performance Not Met: GPD40N3B"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "Able; RadNet PD40-Q1M1-OA Procedure"] P1
    where P1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P1.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Procedure, Performed": "Able; Denominator: GPD40N2A"] P1 P2
      such that P2.relevantPeriod starts during P1.relevantPeriod

// Populations

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: GPD40D1B":
  // config_link_id: GPD40D1B
  exists(["Procedure, Performed": "Able; RadNet Patient Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: GPD40N3A":
  // config_link_id: GPD40N3A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD40N3A"] P2
      such that P2.relevantPeriod starts during [start of P1.relevantPeriod, 30 days after start of P1.relevantPeriod]
        and P2.relevantPeriod starts during "Measurement Period)

define "Numerator Performance Not Met: GPD40N3B":
  // config_link_id: GPD40N3B
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD40N3B"] P2
      such that P2.relevantPeriod starts during [start of P1.relevantPeriod, 30 days after start of P1.relevantPeriod]
        and P2.relevantPeriod starts during "Measurement Period)

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD40D1B"
  and not "Numerator Performance Met: GPD40N3A"
  and not "Numerator Performance Not Met: GPD40N3B"
