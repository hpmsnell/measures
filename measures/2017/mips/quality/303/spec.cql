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

valueset "MIPS; MIPS 303 Encounter"
valueset "MIPS; MIPS 303 Encounter Modifier"
valueset "MIPS; Performance Met: G0913"
valueset "MIPS; Denominator Exception: G0914"
valueset "MIPS; Performance Not Met: G0915"

// VSAC Value Sets

valueset "VSAC; Visual Acuity 20/40 or Better": '2.16.840.1.113883.3.526.3.1483'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Cataract Surgery":
  ["Encounter, Performed": "MIPS; MIPS 303 Encounter"] E
    where E.relevantPeriod starts during Interval[start of "Measurement Period", 3 months before end "Measurement Period"]
      AgeInYearsAt >= 18
      and not E.code.modifier in "MIPS; MIPS 303 Encounter Modifier"
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  exists("Cataract Surgery")

define "Numerator Performance Met: G0913":
  /*
   * config_link_id: G0913
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G0913"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G0914":
  /*
   * config_link_id: G0914
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G0914"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G0915":
  /*
   * config_link_id: G0915
   */
  not "Numerator Performance Met: G0913"
  and not "Denominator Exception: G0914"
