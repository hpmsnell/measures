library MIPS_225_2017 version '1'

/*
 * Source: MIPS
 * ID: 225
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 225 Procedure"
valueset "MIPS; MIPS 225 Mammogram"
valueset "MIPS; Performance Met: 7025F"
valueset "MIPS; Denominator Exception: 7025F-1P"
valueset "MIPS; Performance Not Met: 7025F-8P"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 225 Procedure"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.pqrsProvider = true

define "Mammogram":
  ["Diagnosis": "MIPS; MIPS 225 Mammogram"] D
    where D.relevantPeriod starts during "Measurement Period"

define "Denominator":
  exists("Denominator Procedure")
  and exists("Mammogram")

define "Numerator Performance Met: 7025F":
  /*
   * config_link_id: 7025F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 7025F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 7025F-1P":
  /*
   * config_link_id: 7025F-1P
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 7025F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "VSAC; Limited Life Expectancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Not Met: 7025F-8P":
  /*
   * config_link_id: 7025F-8P
   */
  not "Numerator Performance Met: 7025F"
  and not "Denominator Exception: 7025F-1P"
