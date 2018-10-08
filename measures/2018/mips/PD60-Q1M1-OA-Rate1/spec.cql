library RADNET_PD60-Q1M1-OA_Rate_1_2018 version '1'

/*
 *
 * Source: RadNet
 * ID: PD60-Q1M1-OA
 * Rate: 1
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// Custom value sets (Able)

valueset "Able; RadNet Advanced Image Testing Procedure"
valueset "Able; RadNet Patient Exclusion"
valueset "Able; Performance Met: GPD60N1A"
valueset "Able; Denominator Exception: GPD60N1X"
valueset "Able; Performance Not Met: GPD60N1C"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "Able; RadNet Advanced Image Testing Procedure"] P
    where P.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and P.status not in ["Void","OrderCancelled","PendingCancellation","Cancelled","Discontinued"]

// Populations

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: GPD60D1A":
  // config_link_id: GPD60D1A
  exists(["Procedure, Performed": "Able; RadNet Patient Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: GPD60N1A":
  // config_link_id: GPD60N1A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD60N1A"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Denominator Exception: GPD60N1X":
  // config_link_id: GPD60N1X
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Denominator Exception: GPD60N1X"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD60N1C":
  // config_link_id: GPD60N1C
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Not Met: GPD60N1C"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD60D1A"
  and not "Numerator Performance Met: GPD60N1A"
  and not "Denominator Exception: GPD60N1X"
  and not "Numerator Performance Not Met: GPD60N1C"
