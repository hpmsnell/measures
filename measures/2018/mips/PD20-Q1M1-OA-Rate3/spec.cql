library RADNET_PD20-Q1M1-OA_Rate_3_2018 version '1'

/*
 *
 * Source: RadNet
 * ID: PD20-Q1M1-OA
 * Rate: 3
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// Custom value sets (Able)

valueset "Able; RadNet Advanced Image Testing Procedure"
valueset "Able; Performance Met: GPD20N2A"
valueset "Able; RadNet Patient Exclusion"
valueset "Able; Denominator Exclusion: GPD20N1X"
valueset "Able; Performance Met: GPD20N3A"
valueset "Able; Performance Not Met: GPD20N3C"
valueset "Able; Performance Not Met: GPD20N3B"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Ordered": "Able; RadNet Advanced Image Testing Procedure"] P1
    where P1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P1.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

// Populations

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: GPD20D1B":
  // config_link_id: GPD20D1B
  exists(["Procedure, Performed": "Able; RadNet Patient Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: GPD20N1X":
  // config_link_id: GPD20N1X
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Denominator Exception: GPD20N1X"] P2
      such that P.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: Procedure Not Completed":
  // config_link_id: not_completed
  exists("Denominator Procedure" P
    where P.status not in ["Cancelled","Discontinued"])

define "Numerator Performance Met: GPD20N3A":
  // config_link_id: GPD20N3A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD20N3A"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD20N3C":
  // config_link_id: GPD20N3C
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD20N3C"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD20N3B":
  // config_link_id: GPD20N3B
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD20N3B"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD20D1B"
  and not "Numerator Performance Met: GPD20N3A"
  and not "Numerator Performance Not Met: GPD20N3C"
  and not "Numerator Performance Not Met: GPD20N3B"
  and not "Numerator Performance Not Met: Procedure Not Completed"
