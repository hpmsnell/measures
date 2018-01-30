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
valueset "MIPS; Telehealth Modifier"
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

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Tobacco Interval": Interval[24 months before end "Measurement Period", end "Measurement Period")

define "Exception Exists":
  exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "VSAC; Limited Life Expectancy"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator":
  "Measure 226 Rate 1: Performance Met: G9902"

define "Numerator Performance Met: G9906":
  /*
   * config_link_id: G9906
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9906"] P
    where P.relevantPeriod starts during "Measurement Period")
  exists(["Intervention, Performed": "VSAC; Tobacco Use Cessation Counseling"] I
    where I.relevantPeriod starts during "Tobacco Interval")
  or exists(["Medication": "VSAC; Tobacco Use Cessation Pharmacotherapy"] M
    where M.relevantPeriod overlaps "Tobacco Interval")

define "Denominator Exception: G9907":
  /*
   * config_link_id: G9907
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9907"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Exception Exists"

define "Numerator Performance Not Met: G9908":
  /*
   * config_link_id: G9908
   */
   not "Numerator Performance Met: G9906"
   and not "Denominator Exception: G9907"
