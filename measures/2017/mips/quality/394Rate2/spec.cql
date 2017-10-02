library MIPS_394Rate2_2017 version '1'

/*
 * Source: MIPS
 * ID: 394
 * Year: 2017
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

valueset "Able; DTaP Vaccine": '2.16.840.1.113883.3.464.1003.196.12.1214'
valueset "VSAC; DTaP Vaccine Administered": '2.16.840.1.113883.3.464.1003.110.12.1022'
valueset "VSAC; Anaphylactic Reaction to DTaP Vaccine": '2.16.840.1.113883.3.464.1003.199.12.1031'
valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// Able Value Sets

valueset "Able; HPV Vaccine"
valueset "Able; Meningococcal Vaccine"
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
  ["Allergy": "Able; DTaP Vaccine"]
  union ["Allergy": "Able; Tetanus Vaccine"]
  union ["Allergy": "Able; Diphtheria Vaccine"]
  union ["Allergy": "Able; Pertussis Vaccine"]
  union ["Allergy": "Able; HPV Vaccine"]
  union ["Allergy": "Able; Meningococcal Vaccine"]
  union ["Diagnosis": "VSAC; Anaphylactic Reaction to DTaP Vaccine"]
  union ["Diagnosis": "Able; Allergy to Meningococcal Vaccine"]

define "DTaP Vaccine":
  ["Immunization, Administered": "Able; DTaP Vaccine"]
  union ["Procedure, Performed": "VSAC; DTaP Vaccine Administered"]

define "Tetanus Vaccine":
  ["Immunization, Administered": "VSAC; Tetanus Vaccine"]
  union ["Procedure, Performed": "VSAC; Tetanus Vaccine Administered"]

define "Diphtheria Vaccine":
  ["Immunization, Administered": "VSAC; Diphtheria Vaccine"]
  union ["Procedure, Performed": "VSAC; Diphtheria Vaccine Administered"]

define "Pertussis Vaccine":
  ["Immunization, Administered": "VSAC; Pertussis Vaccine"]
  union ["Procedure, Performed": "VSAC; Pertussis Vaccine Administered"]

define "DTaP Vaccines Exist":
  exists("Tetanus Vaccine" I
    where AgeInYearsAt(I.authorDateTime) >= 10
      and AgeInYearsAt(I.authorDateTime) < 13)
  and exists("Diptheria Vaccine" I
    where AgeInYearsAt(I.authorDateTime) >= 10
      and AgeInYearsAt(I.authorDateTime) < 13)
  and exists("Pertussis Vaccine" I
    where AgeInYearsAt(I.authorDateTime) >= 10
      and AgeInYearsAt(I.authorDateTime) < 13)

define "DTaP Vaccine Exists"
  exists("DTaP Vaccine" I
    where AgeInYearsAt(I.authorDateTime) >= 10
      and AgeInYearsAt(I.authorDateTime) < 13)
  or "DTaP Vaccines Exist"

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
  or "DTaP Vaccine Exists"

define "Numerator Performance Not Met: G9417":
  /*
   * config_link_id: G9821
   */
  not "Denominator Exclusion 1"
  and not "Denominator Exclusion 2"
  and not "Numerator Performance Met: G9416"
