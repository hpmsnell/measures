library MIPS_394Rate1_2017 version '1'

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
valueset "MIPS; Performance Met: G9414"
valueset "MIPS; Performance Not Met: G9415"

// VSAC Value Sets

valueset "VSAC; Anaphylactic Reaction to DTaP Vaccine": '2.16.840.1.113883.3.464.1003.199.12.1031'
valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// Able Value Sets

valueset "Able; HPV Vaccine"
valueset "Able; Meningococcal Vaccine"
valueset "Able; Meningococcal Vaccine Administered"
valueset "Able; Allergy to Meningococcal Vaccine"
valueset "Able; Tetanus Vaccine"
valueset "Able; Diphtheria Vaccine"
valueset "Able; Pertussis Vaccine"
valueset "Able; DTaP Vaccine"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 394 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
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

define "Meningococcal Vaccine":
  ["Immunization, Administered": "Able; Meningococcal Vaccine"]
  union ["Procedure, Performed": "Able; Meningococcal Vaccine Administered"]

define "Meningococcal Vaccine Exists"
  exists("Meningococcal Vaccine" I
    where AgeInYearsAt(I.authorDateTime) >= 11
      and AgeInYearsAt(I.authorDateTime) < 13)

define "Denominator":
  exists("Denominator Encounter")
  and AgeInYearsAt(end of "Measurement Period") = 13

define "Denominator Exclusion 1":
  /*
   * config_link_id: exclusion_1
   */
  exists("Vaccination Allergy" A
    where A.prevalencePeriod overlaps "Denominator Period")

define "Denominator Exclusion 2":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Procedure, Performed": "MIPS; MIPS Hospice Service"] P
    where P.relevantPeriod starts during "Denominator Period")
  or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Denominator Period")

define "Numerator Performance Met: G9414":
  /*
   * config_link_id: G9414
   */
   exists(["Procedure, Performed": "MIPS: Performance Met: G9414"] P
     where AgeInYearsAt(start of P.relevantPeriod) >= 11
       and AgeInYearsAt(start of P.relevantPeriod) < 13)
  or "Meningococcal Vaccine Exists"

define "Numerator Performance Not Met: G9415":
  /*
   * config_link_id: G9821
   */
  not "Denominator Exclusion 1"
  and not "Denominator Exclusion 2"
  and not "Numerator Performance Met: G9414"
