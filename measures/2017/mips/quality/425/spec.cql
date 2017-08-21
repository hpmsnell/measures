library MIPS_425_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 425
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 425 Procedure"
valueset "MIPS; Post-Surgical Colon Anatomy"
valueset "MIPS; Performance Met: G9612"
valueset "MIPS; Performance Not Met: G9614"

// VSAC value sets

valueset "VSAC; Colon Surgery": '2.16.840.1.113883.3.666.5.705'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 425 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {73, 74}

define "Post-Surgical Anatomy":
  ["Procedure, Performed": "MIPS; Post-Surgical Colon Anatomy"]
  union ["Procedure, Performed": "VSAC; Colon Surgery"]

define "Denominator":
  "Denominator Procedure"

define "Denominator Exception":
  /*
   * config_link_id: exception_1
   */
  exists("Post-Surgical Anatomy" P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts before end of E.relevantPeriod)

define "Numerator Performance Met: G9612":
  /*
   * config_link_id: G9612
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9612"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9614":
  /*
   * config_link_id: G9614
   */
  not "Denomiantor Exception"
  and not "Numerator Performance Met: G9612"
