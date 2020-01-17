library MIPS_385_2018 version '1'

/*
 * Source: MIPS
 * ID: 385
 * Year: 2018
 * Version: 2
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 385 Procedure"
valueset "MIPS; Denominator Exclusion: G9757"
valueset "MIPS; Performance Met: G9516"
valueset "MIPS; Performance Not Met: G9517"

// Able value Sets

valueset "Able; Visual Acuity Left Eye"
valueset "Able; Visual Acuity Right Eye"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 385 Procedure"] P
    where P.relevantPeriod starts during Interval[start of "Measurement Period", 3 months before end "Measurement Period"]
      and AgeInYearsAt(start of P.relevantPeriod) >= 18
      and P.signingProvider.hasMeasureMembership = true

define "Preoperative Visual Acuity Left Eye Result":
  ["Assessment, Performed": "Able; Visual Acuity Left Eye"] A
    with ["Procedure, Performed": "MIPS; MIPS 385 Procedure"] P
      such that A.authorDateTime on or 30 days or less before start of P.relevantPeriod
    return A.result

define "Preoperative Visual Acuity Right Eye Result":
  ["Assessment, Performed": "Able; Visual Acuity Right Eye"] A
    with ["Procedure, Performed": "MIPS; MIPS 385 Procedure"] P
      such that A.authorDateTime on or 30 days or less before start of P.relevantPeriod
    return A.result

define "Postoperative Visual Acuity Left Eye Result":
  ["Assessment, Performed": "Able; Visual Acuity Left Eye"] A
    with ["Procedure, Performed": "MIPS; MIPS 385 Procedure"] P
      such that A.authorDateTime 90 days or less after start of P.relevantPeriod
    return A.result

define "Postoperative Visual Acuity Right Eye Result":
  ["Assessment, Performed": "Able; Visual Acuity Right Eye"] A
    with ["Procedure, Performed": "MIPS; MIPS 385 Procedure"] P
      such that A.authorDateTime 90 days or less after start of P.relevantPeriod
    return A.result

/* Populations */

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: G9757":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Procedure, Performed": "MIPS; Procedures Using Silicone Oil"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Met: G9516":
  /*
   * config_link_id: G9516
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9516"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 90 days or less after start of E.relevantPeriod)
  or "Postoperative Visual Acuity Left Eye Result" > "Preoperative Visual Acuity Left Eye Result"
  or "Postoperative Visual Acuity Right Eye Result" > "Preoperative Visual Acuity Right Eye Result"

define "Numerator Performance Not Met: G9517":
  /*
   * config_link_id: G9517
   */
  not "Denominator Exclusion: G9757"
  and not "Numerator Performance Met: G9516"
