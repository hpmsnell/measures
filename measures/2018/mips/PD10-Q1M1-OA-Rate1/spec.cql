library RADNET_PD10-Q1M1-OA_Rate_1_2018 version '1'

/*
 *
 * Source: RadNet
 * ID: PD10-Q1M1-OA
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
valueset "Able; Performance Met: GPD10N1A"
valueset "Able; Performance Met: GPD10N1B"
valueset "Able; Performance Met: GPD10N1C"
valueset "Able; Performance Met: GPD10N1D"
valueset "Able; Performance Met: GPD10N1E"
valueset "Able; Performance Not Met: GPD10N1F"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Ordered": "Able; RadNet Advanced Image Testing Procedure"] P
    where P.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P.relevantPeriod) >= 18
      and P.signingProvider.hasMeasureMembership = true

// Populations

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: GPD10D1A":
  // config_link_id: GPD10D1A
  exists(["Procedure, Performed": "Able; RadNet Patient Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: GPD10N1A":
  // config_link_id: GPD10N1A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N1A"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD10N1B":
  // config_link_id: GPD10N1B
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N1B"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD10N1C":
  // config_link_id: GPD10N1C
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N1C"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD10N1D":
  // config_link_id: GPD10N1D
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N1D"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Met: GPD10N1E":
  // config_link_id: GPD10N1E
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N1E"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD10N1F":
  // config_link_id: GPD10N1F
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Not Met: GPD10N1F"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: Procedure Not Completed":
  // config_link_id: not_completed
  exists("Denominator Procedure" P
    where P.status not in ["Void","OrderCancelled","PendingCancellation","Cancelled","Discontinued"])

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD10D1A"
  and not "Numerator Performance Met: GPD10N1A"
  and not "Numerator Performance Met: GPD10N1B"
  and not "Numerator Performance Met: GPD10N1C"
  and not "Numerator Performance Met: GPD10N1D"
  and not "Numerator Performance Met: GPD10N1E"
  and not "Numerator Performance Not Met: Procedure Not Completed"
  and not "Numerator Performance Not Met: GPD10N1F"
