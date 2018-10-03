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

valueset "Able; RadNet Advanced Image Testing Procedure"
valueset "Able; RadNet Patient Exclusion"
valueset "Able; Denominator Exclusion: GPD40N1X"
valueset "Able; Performance Met: GPD40N3A"
valueset "Able; Performance Not Met: GPD40N3C"
valueset "Able; Performance Not Met: GPD40N3B"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "Able; RadNet Advanced Image Testing Procedure"] P1
    where P1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P1.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

// Populations

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: GPD40D1B":
  // config_link_id: GPD40D1B
  exists(["Procedure, Performed": "Able; RadNet Patient Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: GPD40N1X":
  // config_link_id: GPD40N1X
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD40N1X"] P2
      such that P2.relevantPeriod starts during [start of P1.relevantPeriod, 30 days after start of P1.relevantPeriod]
        and P2.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: GPD40N3A":
  // config_link_id: GPD40N3A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD40N3A"] P2
      such that P2.relevantPeriod starts during [start of P1.relevantPeriod, 30 days after start of P1.relevantPeriod]
        and P2.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: GPD40N3C":
  // config_link_id: GPD40N3C
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD40N3C"] P2
      such that P2.relevantPeriod starts during [start of P1.relevantPeriod, 30 days after start of P1.relevantPeriod]
        and P2.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: GPD40N3B":
  // config_link_id: GPD40N3B
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD40N3B"] P2
      such that P2.relevantPeriod starts during [start of P1.relevantPeriod, 30 days after start of P1.relevantPeriod]
        and P2.relevantPeriod starts during "Measurement Period")

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD40D1B"
  and not "Denominator Exclusion: GPD40N1X"
  and not "Numerator Performance Met: GPD40N3A"
  and not "Numerator Performance Not Met: GPD40N3C"
  and not "Numerator Performance Not Met: GPD40N3B"
