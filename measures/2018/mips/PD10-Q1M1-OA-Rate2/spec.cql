library RADNET_PD10-Q1M1-OA_Rate_2_2018 version '1'

/*
 *
 * Source: RadNet
 * ID: PD10-Q1M1-OA
 * Rate: 2
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// Custom value sets (Able)

valueset "Able; RadNet PD10-Q1M1-OA Procedure"
valueset "Able; RadNet Patient Exclusion"
valueset "Able; Performance Met: GPD10N1B"
valueset "Able; Performance Met: GPD10N1C"
valueset "Able; Performance Met: GPD10N1D"
valueset "Able; Performance Met: GPD10N1E"
valueset "Able; Performance Met: GPD10N2A"
valueset "Able; Performance Met: GPD10N2B"
valueset "Able; Performance Met: GPD10N2C"
valueset "Able; Performance Met: GPD10N2D"
valueset "Able; Performance Not Met: GPD10N2E"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Positive Screening":
  ["Procedure, Performed": "Able; Performance Met: GPD10N1B"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N1C"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N1D"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N1E"]

define "Denominator Procedure":
  ["Procedure, Performed": "Able; RadNet PD10-Q1M1-OA Procedure"] P1
    where P1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P1.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with "Positive Screening" P2
      such that P2.relevantPeriod starts during P1.relevantPeriod

// Populations

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: GPD10D1A":
  // config_link_id: GPD10D1A
  exists(["Procedure, Performed": "Able; RadNet Patient Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: GPD10N2A":
  // config_link_id: GPD10N2A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N2A"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD10N2B":
  // config_link_id: GPD10N2B
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N2B"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD10N2C":
  // config_link_id: GPD10N2C
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N2C"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD10N2D":
  // config_link_id: GPD10N2D
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N2D"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD10N2E":
  // config_link_id: GPD10N2E
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N2E"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD10D1A"
  and not "Numerator Performance Met: GPD10N2A"
  and not "Numerator Performance Met: GPD10N2B"
  and not "Numerator Performance Met: GPD10N2C"
  and not "Numerator Performance Met: GPD10N2D"
  and not "Numerator Performance Not Met: GPD10N2E"
