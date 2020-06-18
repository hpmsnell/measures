library MIPS_117_2020 version '1'

/*
 * Source: MIPS
 * ID: 117
 * Year: 2020
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 117 Encounter"
valueset "MIPS; Diabetes"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: G2102"
valueset "MIPS; Performance Met: G2103"
valueset "MIPS; Performance Met: G2104"
valueset "MIPS; Performance Met: 3072F"
valueset "MIPS; Performance Not Met: G2102-8P"
valueset "MIPS; Performance Not Met: G2103-8P"
valueset "MIPS; Performance Not Met: G2104-8P"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Retinal or Dilated Eye Exam": '2.16.840.1.113883.3.464.1003.115.12.1088'
valueset "VSAC; Diabetic Retinopathy": '2.16.840.1.113883.3.526.3.327'
valueset "VSAC; Acute Inpatient": '2.16.840.1.113883.3.464.1003.101.12.1083'
valueset "VSAC; Advanced Illness": '2.16.840.1.113883.3.464.1003.110.12.1082'
valueset "VSAC; Care Services in Long-Term Residential Facility": '2.16.840.1.113883.3.464.1003.101.12.1014'
valueset "VSAC; Dementia Medications": '2.16.840.1.113883.3.464.1003.196.12.1510'
valueset "VSAC; Encounter Inpatient": '2.16.840.1.113883.3.666.5.307'
valueset "VSAC; Frailty Diagnosis": '2.16.840.1.113883.3.464.1003.113.12.1074'
valueset "VSAC; Frailty Encounter": '2.16.840.1.113883.3.464.1003.101.12.1088'
valueset "VSAC; Nonacute Inpatient": '2.16.840.1.113883.3.464.1003.101.12.1084'
valueset "VSAC; Nursing Facility Visit": '2.16.840.1.113883.3.464.1003.101.12.1012'
valueset "VSAC; Observation": '2.16.840.1.113883.3.464.1003.101.12.1086'
valueset "VSAC; Outpatient": '2.16.840.1.113883.3.464.1003.101.12.1087'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 117 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and AgeInYearsAt(start of E.relevantPeriod) < 75
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Diabetes"] D
      where D.prevalencePeriod overlaps E.relevantPeriod)

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion":
  /*
   * config_link_id: denominator_exclusion
   */
  exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Denominator Exclusion: Frailty/LTI":
  /*
   * config_link_id: exclusion_frailty_lti
   */
  FrailtyLTIShared."Frailty/LTI Exclusion Exists"

define "Numerator Performance Met: G2102":
  /*
   * config_link_id: G2102
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2102"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Physical Exam, Performed": "VSAC; Retinal or Dilated Eye Exam"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G2103":
  /*
   * config_link_id: G2103
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2103"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: G2104":
  /*
   * config_link_id: G2104
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G2104"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 3072F":
  /*
   * config_link_id: 3072F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3072F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or (
    exists(["Physical Exam, Performed": "VSAC; Retinal or Dilated Eye Exam"] P
      where P.relevantPeriod starts 12 months or less before start "Measurement Period")
    and not exists(["Diagnosis": "VSAC; Diabetic Retinopathy"] D
      where D.prevalencePeriod overlaps "Measurement Period")
  )

define "Numerator Performance Not Met: G2102-8P":
  /*
   * config_link_id: G2102-8P
   */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G2102-8P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G2103-8P":
 /*
  * config_link_id: G2103-8P
  */
  exists(["Procedure, Performed": "MIPS; Performance Not Met: G2103-8P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: G2104-8P":
  /*
   * config_link_id: G2104-8P
   */
   not "Denominator Exclusion"
   and not "Numerator Performance Met: G2102"
   and not "Numerator Performance Met: G2103"
   and not "Numerator Performance Met: G2104"
   and not "Numerator Performance Met: 3072F"
   and not "Numerator Performance Not Met: G2102-8P"
   and not "Numerator Performance Not Met: G2103-8P"
