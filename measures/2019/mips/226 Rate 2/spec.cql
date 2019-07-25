library MIPS_226Rate2_2018 version '1'

/*
 * Source: MIPS
 * ID: 226 Rate 2
 * Year: 2018
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 226 Encounter"
valueset "MIPS; MIPS 226 Preventive Encounter"
valueset "MIPS; Performance Met: G9906"
valueset "MIPS; Denominator Exception: G9907"
valueset "MIPS; Performance Not Met: G9908"
valueset "MIPS; MIPS Hospice Service"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Limited Life Expectancy": '2.16.840.1.113883.3.526.3.1259'
valueset "VSAC; Tobacco User": '2.16.840.1.113883.3.526.3.1170'
valueset "VSAC; Tobacco Use Cessation Counseling": '2.16.840.1.113883.3.526.3.509'
valueset "VSAC; Tobacco Use Cessation Pharmacotherapy": '2.16.840.1.113883.3.526.3.1190'

// Able value Sets

valueset "Able; Never Tobacco User"
valueset "Able; Tobacco Use Cessation Intervention Diagnoses"

parameter "Measurement Period" Interval<DateTime>

context Patient

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

define "Encounter":
  "226 Encounter"
  union "226 Preventive Encounter"

define "Latest Encounter":
  Last("Encounter" E
    sort by start of E.relevantPeriod asc)

define "Latest Encounter Start Date":
  "Latest Encounter" E
    return start of E.relevantPeriod

define "Tobacco Interval": Interval[24 months before "Latest Encounter Start Date", "Latest Encounter Start Date")

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
  "Measure 226 Rate 1: Performance Met: G9902"

define "Numerator Performance Met: G9906":
  /*
   * config_link_id: G9906
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9906"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Tobacco Use Cessation Counseling"] I
    where I.relevantPeriod starts during "Tobacco Interval")
  or exists(["Diagnosis": "Able; Tobacco Use Cessation Intervention Diagnoses"] D
    where D.prevalencePeriod starts during "Tobacco Interval")
  or exists(["Medication": "VSAC; Tobacco Use Cessation Pharmacotherapy"] M
    where M.relevantPeriod overlaps "Tobacco Interval")

define "Denominator Exception: G9907":
  /*
   * config_link_id: G9907
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9907"] P
    with "Most Recent Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or "Exception Exists"

define "Numerator Performance Not Met: G9908":
  /*
   * config_link_id: G9908
   */
   not "Numerator Performance Met: G9906"
   and not "Denominator Exception: G9907"
