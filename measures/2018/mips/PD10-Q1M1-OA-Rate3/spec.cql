library RADNET_PD10-Q1M1-OA_Rate_3_2018 version '2'

/*
 *
 * Source: RadNet
 * ID: PD10-Q1M1-OA
 * Rate: 3
 * Year: 2018
 * Version: 2
 * Written by: Steve Daniels
 *
  */

using QDM

// Custom value sets (Able)

valueset "Able; RadNet Advanced Image Testing Procedure"
valueset "Able; RadNet Patient Exclusion"
valueset "Able; Performance Met: GPD10N3A"
valueset "Able; Performance Met: GPD10N3B"
valueset "Able; Performance Met: GPD10N3C"
valueset "Able; Performance Met: GPD10N3D"
valueset "Able; Performance Met: GPD10N3F"
valueset "Able; Performance Met: GPD10N3G"
valueset "Able; Performance Not Met: GPD10N3E"
valueset "Able; Performance Not Met: GPD10N3H"
valueset "Able; Performance Not Met: GPD10N3I"

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

define "Numerator Performance Met: GPD10N3F":
  // config_link_id: GPD10N3F
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3F"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD10N3G":
  // config_link_id: GPD10N3G
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3G"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD10N3E":
  // config_link_id: GPD10N3E
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3E"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD10N3H":
  // config_link_id: GPD10N3H
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3H"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD10N3I":
  // config_link_id: GPD10N3I
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3I"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD10D1A"
  and not "Numerator Performance Met: GPD10N3A"
  and not "Numerator Performance Met: GPD10N3B"
  and not "Numerator Performance Met: GPD10N3C"
  and not "Numerator Performance Met: GPD10N3D"
  and not "Numerator Performance Met: GPD10N3F"
  and not "Numerator Performance Met: GPD10N3G"
  and not "Numerator Performance Not Met: GPD10N3E"
  and not "Numerator Performance Not Met: GPD10N3H"
  and not "Numerator Performance Not Met: GPD10N3I"
