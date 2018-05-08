library MIPS_226Rate1_2018 version '1'

/*
 * Source: MIPS
 * ID: 226 Rate 1
 * Year: 2018
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 226 Encounter"
valueset "MIPS; MIPS 226 Preventive Encounter"
valueset "MIPS; Performance Met: G9902"
valueset "MIPS; Performance Met: G9903"
valueset "MIPS; Denominator Exception: G9904"
valueset "MIPS; Performance Not Met: G9905"
valueset "MIPS; MIPS Hospice Service"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Limited Life Expectancy": '2.16.840.1.113883.3.526.3.1259'
valueset "VSAC; Tobacco Non-User": '2.16.840.1.113883.3.526.3.1189'
valueset "VSAC; Tobacco User": '2.16.840.1.113883.3.526.3.1170'

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
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}

define "226 Preventive Encounter"
  ["Encounter, Performed": "MIPS; MIPS 226 Preventive Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}

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

define "Denominator Encounter":
  "226 Encounter"
  union "226 Preventive Encounter"

define "Most Recent Denominator Encounter":
  Last("Denominator Encounter" E
    sort by start of E.relevantPeriod asc)

define "Hospice Service":
  ["Intervention, Performed": "VSAC; Palliative Care"]
  union ["Intervention, Performed": "MIPS; MIPS Hospice Service"]

define "Exception Exists":
  exists("Hospice Service" I
    with "Most Recent Denominator Encounter" E
      such that I.authorDateTime during E.relevantPeriod)
  or exists(["Diagnosis": "VSAC; Limited Life Expectancy"] D
    with "Most Recent Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)

/* Populations */

define "Denominator":
  count("226 Encounter") >= 2
  or exists("226 Preventive Encounter")

define "Numerator Performance Met: G9902":
  /*
   * config_link_id: G9902
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9902"] P
    where P.relevantPeriod starts during "Tobacco Interval")
  exists("Tobacco User" D
    where D.prevalencePeriod starts during "Tobacco Interval")

define "Numerator Performance Met: G9903":
  /*
   * config_link_id: G9903
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9903"] P
    where P.relevantPeriod starts during "Tobacco Interval")
  or exists("Tobacco Non-User" D
    where D.prevalencePeriod starts during "Tobacco Interval")

define "Denominator Exception: G9904":
  /*
   * config_link_id: G9904
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9904"] P
    with "Most Recent Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or "Exception Exists"

define "Numerator Performance Not Met: G9905":
  /*
   * config_link_id: G9905
   */
   not "Numerator Performance Met: G9902"
   and not "Numerator Performance Met: G9903"
   and not "Denominator Exception: G9904"
