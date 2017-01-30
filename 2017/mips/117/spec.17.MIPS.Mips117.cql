library MIPS_117_2017 version '1'

/*
 * Source: MIPS
 * ID: 117
 * Year: 2017
 * Version: 1
 * Written By: Steve Daniels
 * Reviewed By: Rachel Katz
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 117 Encounter"
valueset "MIPS; Diabetes"
valueset "MIPS; Hospice Service: G9714"
valueset "MIPS; Performance Met: 2022F"
valueset "MIPS; Performance Met: 2024F"
valueset "MIPS; Performance Met: 2026F"
valueset "MIPS; Performance Met: 3072F"

// Able Value Sets

valueset "Able; Diabetic Retinopathy Study 7 field stereoscopic fundus photography"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Retinal or Dilated Eye Exam": '2.16.840.1.113883.3.464.1003.115.12.1088'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  AgeInYearsAt(
    ["Encounter, Performed": "MIPS; MIPS 117 Encounter"] E
      where E.relevantPeriod starts during "Measurement Period"
        and E.signingProvider.pqrsProvider = true
  )

define "Denominator":
  "Patient Age at Encounter" >= 18
  and "Patient Age at Encounter" < 75
  and exists(["Diagnosis": "MIPS; Diabetes"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion":
  /*
   * config_link_id: denominator_exclusion
   */
  exists(["Intervention, Performed": "MIPS; Hospice Service: G9714"] I
    where I.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Met: 2022F":
  /*
   * config_link_id: 2022F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 2022F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Physical Exam, Performed": "VSAC; Retinal or Dilated Eye Exam"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Retinal or Dilated Eye Exam"] P //Same as revious Physical Exam - both are clinical activities
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 2024F": //Confirm whether there are imaging value sets for this and the subsequent reason
  /*
   * config_link_id: 2024F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 2024F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 2026F":
  /*
   * config_link_id: 2026F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 2026F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Met: 3072F":
  /*
   * config_link_id: 3072F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3072F"] P
    where P.relevantPeriod starts during "Measurement Period")
  exists(["Physical Exam, Performed": "VSAC; Retinal or Dilated Eye Exam"] P
    where P.relevantPeriod starts 12 months or less before start "Measurement Period"
      and P.result = 'negative') // Confirm result format in production data

define "Numerator Performance Not Met: 2022F-8P":
  /*
   * config_link_id: 2022F-8P
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 2022F-8P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 2024F-8P":
 /*
  * config_link_id: 2024F-8P
  */
  exists(["Procedure, Performed": "MIPS; Performance Met: 2024F-8P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 2026F-8P":
  /*
   * config_link_id: 2026F-8P
   */
   not "Denominator Exclusion"
   and not "Numerator Performance Met: 2022F"
   and not "Numerator Performance Met: 2024F"
   and not "Numerator Performance Met: 2026F"
   and not "Numerator Performance Met: 3072F"
   and not "Numerator Performance Not Met: 2022F"
   and not "Numerator Performance Not Met: 2024F"
