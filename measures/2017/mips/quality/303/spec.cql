library MIPS_303_2017 version '1'

/*
 * Source: MIPS
 * ID: 303
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By:
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 303 Procedure"
valueset "MIPS; Performance Met: G0913"
valueset "MIPS; Denominator Exception: G0914"
valueset "MIPS; Performance Not Met: G0915"

// Able value Sets

valueset "Able; Visual Acuity"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 303 Procedure"] P
    where P.relevantPeriod starts during Interval[start of "Measurement Period", 3 months before end "Measurement Period"]
      and AgeInYearsAt(start of P.relevantPeriod) >= 18
      and not P.code.modifier in {55, 56}
      and P.signingProvider.hasMeasureMembership = true

define "Preoperative Visual Acuity Result":
  ["Assessment, Performed": "Able; Visual Acuity"] A
    with ["Procedure, Performed": "MIPS; MIPS 303 Procedure"] P
      such that A.authorDateTime on or 30 days or less before start of P.relevantPeriod
    return A.result

define "Postoperative Visual Acuity Result":
  ["Assessment, Performed": "Able; Visual Acuity"] A
    with ["Procedure, Performed": "MIPS; MIPS 303 Procedure"] P
      such that A.authorDateTime 90 days or less after start of P.relevantPeriod
    return A.result

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G0913":
  /*
   * config_link_id: G0913
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G0913"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 90 days or less after start of E.relevantPeriod)

define "Denominator Exception: G0914":
  /*
   * config_link_id: G0914
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G0914"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 90 days or less after start of E.relevantPeriod)
  or "Postoperative Visual Acuity Result" > "Preoperative Visual Acuity Result"

define "Numerator Performance Not Met: G0915":
  /*
   * config_link_id: G0915
   */
  not "Numerator Performance Met: G0913"
  and not "Denominator Exception: G0914"
