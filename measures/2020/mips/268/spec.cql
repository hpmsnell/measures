library MIPS_268_2019 version '1'

/*
 * Source: MIPS
 * ID: 268
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 268 Encounter"
valueset "MIPS; Epilepsy"
valueset "MIPS; Performance Met: 4340F"
valueset "MIPS; Denominator Exception: 4340F-1P"
valueset "MIPS; Performance Not Met: 4340F-8P"
valueset "MIPS; Denominator Exclusion: M1016"

// VSAC value sets

valueset "VSAC; Absence of Cervix"
valueset "VSAC; ADHD"
valueset "VSAC; Autism Spectrum and Related Disorders"
valueset "VSAC; Intellectual Disabilities"
valueset "VSAC; Tourette's Syndrome"
valueset "VSAC; Schizophrenia or Psychotic Disorder"
valueset "VSAC; Neonatal Severe Neurological Complications"
valueset "VSAC; Cerebral Palsy"
valueset "VSAC; Brain Injury"
valueset "VSAC; Dementia & Mental Degenerations"

// Able value sets

valueset "Able; Post-Menopausal"
valueset "Able; Female Surgical Sterilization"
valueset "Able; Dyslexia"
valueset "Able; Genetic Neurodevelopmental Disorder"
valueset "Able; Encephalopathy"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 268 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; Epilepsy"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Neurological Disorder":
  ["Diagnosis": "VSAC; ADHD"]
  union ["Diagnosis": "VSAC; Autism Spectrum and Related Disorders"]
  union ["Diagnosis": "Able; Dyslexia"]
  union ["Diagnosis": "VSAC; Intellectual Disabilities"]
  union ["Diagnosis": "VSAC; Tourette's Syndrome"]
  union ["Diagnosis": "Able; Genetic Neurodevelopmental Disorder"]
  union ["Diagnosis": "VSAC; Schizophrenia or Psychotic Disorder"]
  union ["Diagnosis": "VSAC; Neonatal Severe Neurological Complications"]
  union ["Diagnosis": "Able; Encephalopathy"]
  union ["Diagnosis": "VSAC; Cerebral Palsy"]
  union ["Diagnosis": "VSAC; Brain Injury"]
  union ["Diagnosis": "VSAC; Dementia & Mental Degenerations"]

/* POPULATIONS */

define "Denominator":
  "Patient Characteristic Sex" = 'Female'
  and exists("Denominator Encounter")

define "Denominator Exclusion: M1016":
  /*
   * config_link_id: M1016
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exclusion: M1016"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Diagnosis": "VSAC; Absence of Cervix"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Absence of Cervix"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Diagnosis": "Able; Post-Menopausal"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Female Surgical Sterilization"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Diagnosis": "Able; Female Surgical Sterilization"] D
    where D.prevalencePeriod starts before end of "Measurement Period")

define "Numerator Performance Met: 4340F":
  /*
   * config_link_id: 4340F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 4340F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 4340F-1P":
  /*
   * config_link_id: 4340F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4340F-1P"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod)
  or exists("Neurological Disorder" D
    with "Denominator Encounter" E
      such that D.prevalencePeriod overlaps E.relevantPeriod)

define "Numerator Performance Not Met: 4340F-8P":
 /*
  * config_link_id: 4340F-8P
  */
 not "Denominator Exclusion: M1016"
 and not "Numerator Performance Met: 4340F"
 and not "Denominator Exception: 4340F-1P"
