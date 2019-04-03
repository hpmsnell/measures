library MIPS_338_2018 version '1'

/*
 * Source: MIPS
 * ID: 338
 * Year: 2018
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 338 Encounter"
valueset "MIPS; HIV/AIDS"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: G9243"
valueset "MIPS; Performance Not Met: G9242"

// VSAC value sets

valueset "VSAC; HIV Viral Load": '2.16.840.1.113883.3.464.1003.120.12.1002'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 338 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; HIV/AIDS"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Ordered Viral Loads":
  ["Laboratory Test, Performed": "VSAC; HIV Viral Load"] L
    where L.resultDateTime during "Measurement Period"
    sort by L.resultDateTime ASC

/* POPULATIONS */

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: G9243":
  /*
   * config_link_id: G9243
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9243"] P
    where P.relevantPeriod during "Measurement Period"
  or Last("Ordered Viral Loads").result < 200

define "Numerator Performance Not Met: G9242":
 /*
  * config_link_id: G9242
  */
 not "Numerator Performance Met: G9243"
