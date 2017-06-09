library MIPS_357_2017 version '1'

/*
 * Source: MIPS
 * ID: 357
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 357 Procedure"
valueset "MIPS; Performance Met: G9312"
valueset "MIPS; Performance Not Met: G9311"

// Able Value Sets

valueset "Able; Surgical Site Infection"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 357 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of "Measurement Period") >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Denominator":
  exists("Denominator Procedure")

define "Numerator Performance Met: G9312":
  /*
   * config_link_id: G9312
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9312"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed" "Able; Surgical Site Infection"] P
    with "Denominator Procedure" E
      such that P.relevantPeriod starts 30 days or less after end of E.relevantPeriod)

define "Numerator Performance Not Met: G9311":
  /*
   * config_link_id: G9311
   */
  not "Numerator Performance Met: G9312"
