library RADNET_PD20-Q1M1-OA_Rate_1_2018 version '1'

/*
 *
 * Source: RadNet
 * ID: PD20-Q1M1-OA
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// Custom value sets (Able)

valueset "Able; RadNet Advanced Image Testing Procedure"
valueset "Able; Denominator: GPD20D1A"
valueset "Able; RadNet Patient Exclusion"
valueset "Able; Performance Met: GPD20N1A"
valueset "Able; Performance Not Met: GPD20N1B"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "Able; RadNet Advanced Image Testing Procedure"] P1
    where P1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P1.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Procedure, Performed": "Able; Denominator: GPD20D1A"] P1 P2
      such that P2.relevantPeriod starts during P1.relevantPeriod

// Populations

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: GPD20D1B":
  // config_link_id: GPD20D1B
  exists(["Procedure, Performed": "Able; RadNet Patient Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: GPD20N1A":
  // config_link_id: GPD20N1A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD20N1A"] P2
      such that P.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD20N1B":
  // config_link_id: GPD20N1B
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD20N1B"] P2
      such that P.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD20D1B"
  and not "Numerator Performance Met: GPD20N1A"
  and not "Numerator Performance Not Met: GPD20N1B"
