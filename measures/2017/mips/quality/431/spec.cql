library MIPS_431_2017 version '1'

/*
 * Source: MIPS
 * ID: 431
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By: Rachel Katz
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 431 Encounter"
valueset "MIPS; MIPS 431 Preventive Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Performance Met: G9621"
valueset "MIPS; Performance Met: G9622"
valueset "MIPS; Denominator Exception: G9623"
valueset "MIPS; Performance Not Met: G9624"
valueset "MIPS; MIPS Hospice Service"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Limited Life Expectancy": '2.16.840.1.113883.3.526.3.1259'
valueset "VSAC; Alcohol and Drug Dependence Treatment": '2.16.840.1.113883.3.464.1003.106.12.1005'
valueset "VSAC; Moderation of ETOH Consumption Recommendation": '2.16.840.1.113883.3.600.823'

// Able Value Sets

valueset "Able; Alcohol User"
valueset "Able; Alcohol Non-User"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Alcohol Interval": Interval[24 months before end "Measurement Period", end "Measurement Period")

define "431 Encounter"
  ["Encounter, Performed": "MIPS; MIPS 431 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "431 Preventive Encounter"
  ["Encounter, Performed": "MIPS; MIPS 431 Preventive Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "Alcohol User":
  ["Diagnosis": "Able; Alcohol User"]
  union ["Assessment, Performed": "Able; Alcohol User"]

define "Alcohol Non-User":
  ["Diagnosis": "Able; Alcohol Non-User"]
  union ["Assessment, Performed": "Able; Alcohol Non-User"]

define "Alcohol Treatment":
  ["Intervention, Performed": "VSAC; Alcohol and Drug Dependence Treatment"]
  union ["Intervention, Performed": "VSAC; Moderation of ETOH Consumption Recommendation"]

define "Denominator":
  count("431 Encounter") >= 2
  or exists("431 Preventive Encounter")

define "Numerator Performance Met: G9621":
  /*
   * config_link_id: G9621
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9621"] P
    where P.relevantPeriod starts during "Measurement Period")
  or (
    exists("Alcohol User" D
      where D.prevalencePeriod starts during "Alcohol Interval")
    and exists("Alcohol Treatment" I
      where I.relevantPeriod starts during "Tobacco Interval")
  )

define "Numerator Performance Met: G9622":
  /*
   * config_link_id: G9622
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9622"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Alcohol Non-User" D
    where D.prevalencePeriod starts during "Alcohol Interval")

define "Denominator Exception: G9623":
  /*
   * config_link_id: G9623
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9623"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "VSAC; Limited Life Expectancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Not Met: G9624":
  /*
   * config_link_id: G9624
   */
   not "Numerator Performance Met: G9621"
   and not "Numerator Performance Met: G9622"
   and not "Denominator Exception: G9623"
