library RADNET_PD60-Q1M1-OA_Rate_2_2018 version '5'

/*
 *
 * Source: RadNet
 * ID: PD60-Q1M1-OA
 * Rate: 2
 * Year: 2019
 * Version: 5
 * Written by: Steve Daniels
 *
  */

using QDM

// Custom value sets (Able)

valueset "Able; RadNet Advanced Image Testing Procedure"
valueset "Able; Performance Met: GPD60N1A"
valueset "Able; RadNet Patient Exclusion"
valueset "Able; Performance Met: GPD60N2A"
valueset "Able; Performance Not Met: GPD60N2B"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "Able; RadNet Advanced Image Testing Procedure"] P1
    where P1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P1.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and P.status not in ["Void","OrderCancelled","PendingCancellation","Cancelled","Discontinued"]
    with ["Procedure, Performed": "Able; Performance Met: GPD60N1A"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod

// Populations

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: GPD60D1A":
  // config_link_id: GPD60D1A
  exists(["Procedure, Performed": "Able; RadNet Patient Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: GPD60N2A":
  // config_link_id: GPD60N2A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD60N2A"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD60N2B":
  // config_link_id: GPD60N2B
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD60N2B"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD60D1A"
  and not "Numerator Performance Met: GPD60N2A"
  and not "Numerator Performance Not Met: GPD60N2B"
