library MIPS_014_2018 version '1'

/*
 * Source: MIPS
 * ID: 014
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Custom Value Sets

valueset "MIPS; MIPS 014 Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Age-Related Macular Degeneration"
valueset "MIPS; Performance Met: G9890"
valueset "MIPS; Denominator Exception: G9891"
valueset "MIPS; Denominator Exception: G9892"
valueset "MIPS; Performance Not Met: G9893"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 014 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and not E.code.modifier in "MIPS; Telehealth Modifier"
      and AgeInYearsAt(start of E.relevantPeriod) >= 50
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Age-Related Macular Degeneration"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G9890":
  /*
   * config_link_id: G9890
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9890"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: G9891":
  /*
   * config_link_id: G9891
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9891"] P
    where P.relevantPeriod starts during "Measurement Period"
    with "Denominator Encounter" E
      such that P.relevantPeriod starts before E.relevantPeriod)

define "Denominator Exception: G9892":
  /*
   * config_link_id: G9892
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9892"] P
    where P.relevantPeriod starts during "Measurement Period"
    with "Denominator Encounter" E
      such that P.relevantPeriod starts before E.relevantPeriod)

define "Numerator Performance Not Met: G9893":
  /*
   * config_link_id: G9893
   */
  and "Numerator Performance Met: G9890"
  and not "Denominator Exception: G9891"
  and not "Denominator Exception: G9892"
