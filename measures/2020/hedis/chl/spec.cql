library HEDIS_CHL_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CHL
 * Year: 2020
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; Performance Met: G9820" //Chlamydia Screening

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; Pregnancy": '2.16.840.1.113883.3.464.1004.1219'
valueset "HEDIS; Pregnancy Tests": '2.16.840.1.113883.3.464.1004.1221'
valueset "HEDIS; Sexual Activity": '2.16.840.1.113883.3.464.1004.1238'
valueset "HEDIS; Pregnancy Test Exclusion": '2.16.840.1.113883.3.464.1004.1344'
valueset "HEDIS; Diagnostic Radiology": '2.16.840.1.113883.3.464.1004.1081'
valueset "HEDIS; Chlamydia Tests": '2.16.840.1.113883.3.464.1004.1060'
valueset "HEDIS; Retinoid Medications"

// VSAC value sets

valueset "VSAC; Pregnancy Test": '2.16.840.1.113883.3.464.1003.111.12.1011'
valueset "VSAC; Pap Test": '2.16.840.1.113883.3.464.1003.108.12.1017'
valueset "VSAC; Lab Tests During Pregnancy": '2.16.840.1.113883.3.464.1003.111.12.1007'
valueset "VSAC; Lab Tests for Sexually Transmitted Infections": '2.16.840.1.113883.3.464.1003.110.12.1051'
valueset "VSAC; Contraceptive Medications": '2.16.840.1.113883.3.464.1003.196.12.1080'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

define "Denominator Diagnosis":
  ["Diagnosis": "HEDIS; Pregnancy"]
  union ["Diagnosis": "HEDIS; Sexual Activity"]

define "Denominator Procedure":
  ["Procedure, Performed": "HEDIS; Pregnancy Tests"]
  union ["Procedure, Performed": "HEDIS; Sexual Activity"]

define "Denominator Lab Without Pregnancy Test":
union ["Laboratory Test, Performed": "VSAC; Pap Test"]
union ["Laboratory Test, Performed": "VSAC; Lab Tests During Pregnancy"]
union ["Laboratory Test, Performed": "VSAC; Lab Tests for Sexually Transmitted Infections"]

define "Denominator Lab":
  ["Laboratory Test, Performed": "VSAC; Pregnancy Test"]
  union ["Laboratory Test, Performed": "VSAC; Pap Test"]
  union ["Laboratory Test, Performed": "VSAC; Lab Tests During Pregnancy"]
  union ["Laboratory Test, Performed": "VSAC; Lab Tests for Sexually Transmitted Infections"]

define "Sexual Activity Exists":
  exists("Denominator Procedure" P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Denominator Diagnosis" D
    where D.relevantPeriod overlaps "Measurement Period")
  or exists("Denominator Lab" L
    where L.resultDateTime during "Measurement Period")
  or exists(["Medication": "VSAC; Contraceptive Medications"] M
    where M.relevantPeriod overlaps "Measurement Period")

define "Only Pregnancy Test Exists":
  not exists(["Procedure, Performed": "HEDIS; Sexual Activity"] P
    where P.relevantPeriod starts during "Measurement Period")
  and not exists("Denominator Diagnosis" D
    where D.relevantPeriod overlaps "Measurement Period")
  and not exists("Denominator Lab Without Pregnancy Test" L
    where L.resultDateTime during "Measurement Period")
  and not exists(["Medication": "VSAC; Contraceptive Medications"] M
    where M.relevantPeriod overlaps "Measurement Period")

define "Pregnancy Test Exclusion":
  ["Procedure, Performed": "HEDIS; Pregnancy Test Exclusion"]
  union ["Laboratory Test, Performed": "HEDIS; Pregnancy Test Exclusion"]

define "Retinoid or Diagnostic Radiology":
  ["Procedure, Performed": "HEDIS; Diagnostic Radiology"]
  union ["Medication": "HEDIS; Retinoid Medications"]

define "Chlamydia Tests":
  ["Procedure, Performed": "HEDIS; Chlamydia Tests"]
  union ["Laboratory Test, Performed": "HEDIS; Chlamydia Tests"]
  union ["Procedure, Performed": "MIPS; Performance Met: G9820"]

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") >= 16
  and AgeInYearsAt(end of "Measurement Period") < 25
  and "Patient Characteristic Sex" = "Female"
  and "Sexual Activity Exists"
  and not exists("Hospice" I
    where I.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  "Only Pregnancy Test Exists"
  and exists("Pregnancy Test Exclusion" L
    with "Retinoid or Diagnostic Radiology" P
      such that L.resultDateTime on or 6 days or less before start of P.relevantPeriod)

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Chlamydia Tests" P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
