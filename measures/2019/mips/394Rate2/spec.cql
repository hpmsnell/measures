library MIPS_394Rate2_2019 version '1'

/*
 * Source: MIPS
 * ID: 394
 * Year: 2019
 * Version: 1
 * Written By: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 394 Encounter"
valueset "MIPS; MIPS Hospice Service"
valueset "MIPS; Performance Met: G9416"
valueset "MIPS; Performance Not Met: G9417"

// VSAC Value Sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// HEDIS value sets

valueset "HEDIS; Meningococcal Vaccine Administered": '2.16.840.1.113883.3.464.1004.1177'
valueset "HEDIS; HPV Vaccine Administered": '2.16.840.1.113883.3.464.1004.1112'
valueset "HEDIS; Tdap Vaccine Administered": '2.16.840.1.113883.3.464.1004.1245'

// Able Value Sets

valueset "Able; Allergy to Meningococcal Vaccine"
valueset "Able; Tetanus Vaccine"
valueset "Able; Tetanus Vaccine Administered"
valueset "Able; Diphtheria Vaccine"
valueset "Able; Diphtheria Vaccine Administered"
valueset "Able; Pertussis Vaccine"
valueset "Able; Pertussis Vaccine Administered"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 394 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true

define "Vaccination Allergy":
  ["Allergy": "HEDIS; Tdap Vaccine Administered"]
  union ["Allergy": "Able; Tetanus Vaccine"]
  union ["Allergy": "Able; Diphtheria Vaccine"]
  union ["Allergy": "Able; Pertussis Vaccine"]
  union ["Allergy": "HEDIS; HPV Vaccine Administered"]
  union ["Allergy": "HEDIS; Meningococcal Vaccine Administered"]
  union ["Diagnosis": "Able; Allergy to Meningococcal Vaccine"]

define "Tdap Vaccine":
  ["Immunization, Administered": "HEDIS; Tdap Vaccine Administered"]
  union ["Procedure, Performed": "HEDIS; Tdap Vaccine Administered"]

define "Tetanus Vaccine":
  ["Immunization, Administered": "VSAC; Tetanus Vaccine"]
  union ["Procedure, Performed": "VSAC; Tetanus Vaccine Administered"]

define "Diphtheria Vaccine":
  ["Immunization, Administered": "VSAC; Diphtheria Vaccine"]
  union ["Procedure, Performed": "VSAC; Diphtheria Vaccine Administered"]

define "Pertussis Vaccine":
  ["Immunization, Administered": "VSAC; Pertussis Vaccine"]
  union ["Procedure, Performed": "VSAC; Pertussis Vaccine Administered"]

define "Tdap Vaccines Exist":
  exists("Tetanus Vaccine" I
    where AgeInYearsAt(I.authorDateTime) >= 10
      and AgeInYearsAt(I.authorDateTime) < 13)
  and exists("Diptheria Vaccine" I
    where AgeInYearsAt(I.authorDateTime) >= 10
      and AgeInYearsAt(I.authorDateTime) < 13)
  and exists("Pertussis Vaccine" I
    where AgeInYearsAt(I.authorDateTime) >= 10
      and AgeInYearsAt(I.authorDateTime) < 13)

define "Tdap Vaccine Exists"
  exists("Tdap Vaccine" I
    where AgeInYearsAt(I.authorDateTime) >= 10
      and AgeInYearsAt(I.authorDateTime) < 13)
  or "Tdap Vaccines Exist"

define "Denominator":
  exists("Denominator Encounter")
  and AgeInYearsAt(end of "Measurement Period") = 13

define "Denominator Exclusion 1":
  /*
   * config_link_id: exclusion_1
   */
  exists("Vaccination Allergy" A
    where A.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exclusion 2":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Met: G9416":
  /*
   * config_link_id: G9416
   */
  exists(["Procedure, Performed": "MIPS: Performance Met: G9416"] P
    where AgeInYearsAt(start of P.relevantPeriod) >= 10
      and AgeInYearsAt(start of P.relevantPeriod) < 13)
  or "Tdap Vaccine Exists"

define "Numerator Performance Not Met: G9417":
  /*
   * config_link_id: G9821
   */
  not "Denominator Exclusion 1"
  and not "Denominator Exclusion 2"
  and not "Numerator Performance Met: G9416"
