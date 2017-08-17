library MIPS_226_2017 version '1'

/*
 * Source: MIPS
 * ID: 226
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By: Rachel Katz
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 226 Encounter"
valueset "MIPS; MIPS 226 Preventive Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Performance Met: 4004F"
valueset "MIPS; Performance Met: 1036F"
valueset "MIPS; Denominator Exception: 4004F-1P"
valueset "MIPS; Performance Not Met: 4004F-8P"
valueset "MIPS; MIPS Hospice Service"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Limited Life Expectancy": '2.16.840.1.113883.3.526.3.1259'
valueset "VSAC; Tobacco Non-User": '2.16.840.1.113883.3.526.3.1189'
valueset "VSAC; Tobacco User": '2.16.840.1.113883.3.526.3.1170'
valueset "VSAC; Tobacco Use Cessation Counseling": '2.16.840.1.113883.3.526.3.509'
valueset "VSAC; Tobacco Use Cessation Pharmacotherapy": '2.16.840.1.113883.3.526.3.1190'

// Able value Sets

valueset "Able; Never Tobacco User"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Tobacco Interval": Interval[24 months before end "Measurement Period", end "Measurement Period")

define "226 Encounter"
  ["Encounter, Performed": "MIPS; MIPS 226 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "226 Preventive Encounter"
  ["Encounter, Performed": "MIPS; MIPS 226 Preventive Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "Tobacco User":
  ["Diagnosis": "VSAC; Tobacco User"]
  union ["Assessment, Performed": "VSAC; Tobacco User"]

define "Tobacco Non-User":
  ["Diagnosis": "VSAC; Tobacco Non-User"]
  union ["Assessment, Performed": "VSAC; Tobacco Non-User"]
  union ["Diagnosis": "Able; Never Tobacco User"]
  union ["Assessment, Performed": "Able; Never Tobacco User"]

define "Denominator":
  count("226 Encounter") >= 2
  or exists("226 Preventive Encounter")

define "Numerator Performance Met: 4004F":
  /*
   * config_link_id: 4004F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4004F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or (
    exists("Tobacco User" D
      where D.prevalencePeriod starts during "Tobacco Interval")
    and (
      exists(["Intervention, Performed": "VSAC; Tobacco Use Cessation Counseling"] I
        where I.relevantPeriod starts during "Tobacco Interval")
      or exists(["Medication, Order": "VSAC; Tobacco Use Cessation Pharmacotherapy"] M
        where M.authorDateTime during "Tobacco Interval")
      or exists(["Medication, Active": "VSAC; Tobacco Use Cessation Pharmacotherapy"] M
        where M.relevantPeriod overlaps "Tobacco Interval")
    )
  )

define "Numerator Performance Met: 1036F":
  /*
   * config_link_id: 1036F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 1036F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Tobacco Non-User" D
    where D.prevalencePeriod starts during "Tobacco Interval")

define "Denominator Exception: 4004F-1P":
  /*
   * config_link_id: 4004F-1P
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4004F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "VSAC; Limited Life Expectancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Not Met: 4004F-8P":
  /*
   * config_link_id: 4004F-8P
   */
   not "Numerator Performance Met: 4004F"
   and not "Numerator Performance Met: 1036F"
   and not "Denominator Exception: 4004F-1P"
