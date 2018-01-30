library MIPS_226Rate3_2018 version '1'

/*
 * Source: MIPS
 * ID: 226 Rate 3
 * Year: 2018
 * Version: 1
 * Written By: Steve Daniels
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
valueset "MIPS; Denominator Exception: G9909"
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
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Tobacco Interval": Interval[24 months before end "Measurement Period", end "Measurement Period")

define "226 Encounter"
  ["Encounter, Performed": "MIPS; MIPS 226 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in "MIPS; Telehealth Modifier"

define "226 Preventive Encounter"
  ["Encounter, Performed": "MIPS; MIPS 226 Preventive Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
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

define "Screening"
  "Tobacco User"
  union "Tobacco Non-User"

define "Exception Exists":
  exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "VSAC; Limited Life Expectancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Exception for Not Screening":
  not exists("Screening" D
    where D.prevalencePeriod starts during "Tobacco Interval")
  and "Exception Exists"

define "Exception for Not Performing Intervention":
  exists("Tobacco User" D
    where D.prevalencePeriod starts during "Tobacco Interval")
  and "Exception Exists"

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
      or exists(["Medication": "VSAC; Tobacco Use Cessation Pharmacotherapy"] M
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
  or "Exception for Not Screening"

define "Denominator Exception: G9909":
  /*
   * config_link_id: G9909
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9909"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Exception for Not Providing Intervention"

define "Numerator Performance Not Met: 4004F-8P":
  /*
   * config_link_id: 4004F-8P
   */
   not "Numerator Performance Met: 4004F"
   and not "Numerator Performance Met: 1036F"
   and not "Denominator Exception: 4004F-1P"
   and not "Denominator Exception: G9909"
