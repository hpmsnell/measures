library RADNET_PD10-Q1M1-OA_Rate_3_2018 version '1'

/*
 *
 * Source: RadNet
 * ID: PD10-Q1M1-OA
 * Rate: 3
 * Year: 2018
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// Custom value sets (Able)

valueset "Able; RadNet PD10-Q1M1-OA Procedure"
valueset "Able; RadNet Patient Exclusion"
valueset "Able; Performance Met: GPD10N2A"
valueset "Able; Performance Met: GPD10N2B"
valueset "Able; Performance Met: GPD10N2C"
valueset "Able; Performance Met: GPD10N2D"
valueset "Able; Performance Met: GPD10N3A"
valueset "Able; Performance Met: GPD10N3B"
valueset "Able; Performance Met: GPD10N3C"
valueset "Able; Performance Met: GPD10N3D"
valueset "Able; Performance Not Met: GPD10N3E"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Positive Screening with Follow-Up":
  ["Procedure, Performed": "Able; Performance Met: GPD10N2A"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N2B"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N2C"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N2D"]

define "Denominator Procedure":
  ["Procedure, Performed": "Able; RadNet PD10-Q1M1-OA Procedure"] P1
    where P1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P1.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with "Positive Screening with Follow-Up" P2
      such that P2.relevantPeriod starts during P1.relevantPeriod

// Populations

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: GPD10D1A":
  // config_link_id: GPD10D1A
  exists(["Procedure, Performed": "Able; RadNet Patient Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: GPD10N3A":
  // config_link_id: GPD10N3A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3A"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD10N3B":
  // config_link_id: GPD10N3B
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3B"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD10N3C":
  // config_link_id: GPD10N3C
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3C"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD10N3D":
  // config_link_id: GPD10N3D
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3D"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD10N3E":
  // config_link_id: GPD10N3E
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3E"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD10D1A"
  and not "Numerator Performance Met: GPD10N3A"
  and not "Numerator Performance Met: GPD10N3B"
  and not "Numerator Performance Met: GPD10N3C"
  and not "Numerator Performance Met: GPD10N3D"
  and not "Numerator Performance Not Met: GPD10N3E"
