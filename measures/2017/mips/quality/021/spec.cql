library MIPS_021_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 021
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 021 Procedure"
valueset "MIPS; Performance Met: G9197"
valueset "MIPS; Denominator Exception: G9196"
valueset "MIPS; Performance Not Met: G9198"

// Able value sets

valueset "Able; First Generation Cephalosporin"
valueset "Able; Second Generation Cephalosporin"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 021 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "First or Second Generation Cephalosporin":
  ["Medication": "Able; First Generation Cephalosporin"]
  union ["Medication": "Able; Second Generation Cephalosporin"]

define "Denominator":
  "Denominator Procedure"

define "Numerator Performance Met: G9197":
  /*
   * config_link_id: G9197
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9197"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("First or Second Generation Cephalosporin" M
    with "Denominator Procedure" E
      such that M.relevantPeriod starts during E.relevantPeriod)

define "Denominator Exception: G9196":
  /*
   * config_link_id: G9196
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9196"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts during E.relevantPeriod)

define "Numerator Performance Not Met: G9198":
  /*
   * config_link_id: G9198
   */
  not "Numerator Performance Met: G9197"
  anf not "Denominator Exception: G9196"
