library RADNET_PD40-Q1M1-OA_Rate_1_2018 version '1'

/*
 *
 * Source: RadNet
 * ID: PD40-Q1M1-OA
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
valueset "Able; Performance Met: GPD40N1A"
valueset "Able; Denominator Exception: GPD40N1X"
valueset "Able; Performance Not Met: GPD40N1B"
valueset "Able; Performance Not Met: GPD40N1C"

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
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; RadNet Patient Exclusion"] P2
      such that P.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD40N1A":
  // config_link_id: GPD40N1A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD40N1A"] P2
      such that P.relevantPeriod starts during P1.relevantPeriod)

define "Denominator Exception: GPD40N1X":
  // config_link_id: GPD40N1X
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD40N1X"] P2
      such that P.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: Procedure Not Completed":
  // config_link_id: not_completed
  exists("Denominator Procedure" P
    where P.status not in ["Cancelled","Discontinued"])

define "Numerator Performance Not Met: GPD40N1B":
  // config_link_id: GPD40N1B
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Not Met: GPD40N1B"] P2
      such that P.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD40N1C":
  // config_link_id: GPD40N1C
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Not Met: GPD40N1C"] P2
      such that P.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD40D1B"
  and not "Numerator Performance Met: GPD40N1A"
  and not "Denominator Exception: GPD40N1X"
  and not "Numerator Performance Not Met: Procedure Not Completed"
  and not "Numerator Performance Not Met: GPD40N1B"
  and not "Numerator Performance Not Met: GPD40N1C"
