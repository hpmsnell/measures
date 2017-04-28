library MIPS_047_2017 version '1'

/*
 * Source: MIPS
 * ID: 047
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// Able Custom Value Sets

valueset "MIPS; MIPS 047 Encounter"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: 1123F"
valueset "MIPS; Performance Met: 1124F"
valueset "MIPS; Performance Not Met: 1123F-8P"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// Able Value Sets

valueset "ABLE; Advance Directive"
valueset "ABLE; Advance Directive Discussed"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 047 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 65
      and E.signingProvider.pqrsProvider = true

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Met: 1123F":
  /*
   * config_link_id: 1123F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 1123F"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists("Procedure, Performed": "ABLE; Advance Directive") P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Numerator Performance Met: 1124F":
  /*
   * config_link_id: 1124F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 1124F"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists("Procedure, Performed": "ABLE; Advance Directive Discussed") P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Numerator Performance Not Met: 1123F-8P":
  /*
   * config_link_id: 1123F-8P
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met: 1123F"
  and not "Numerator Performance Met: 1124F"
