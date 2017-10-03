library MIPS_224Rate1_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 224
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 224 Encounter"
valueset "MIPS; MIPS 224 Melanoma"
valueset "MIPS; Stage 0 through IIC Melanoma"
valueset "MIPS; Absence of Signs of Melanoma"
valueset "MIPS; Performance Met: 3320F"
valueset "MIPS; Denominator Exception: 3319F-1P"
valueset "MIPS; Denominator Exception: 3319F-3P"
valueset "MIPS; Performance Not Met: 3319F-8P"

// VSAC value sets

valueset "VSAC; Chest XRay Diagnostic Test"

// Able value sets

valueset "Able; CT Scan"
valueset "Able; MRI"
valueset "Able; PET Scan"
valueset "Able; Nuclear Medicine Scan"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 224 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ', 'GT'}
    with ["Diagnosis": "MIPS; MIPS 224 Melanoma"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod
    with ["Assessment, Performed": "MIPS; Stage 0 through IIC Melanoma"] A1
      such that A1.relevantPeriod starts during D.prevalencePeriod
    with ["Assessment, Performed": "MIPS; Absence of Signs of Melanoma"] A2
      such that A2.relevantPeriod starts during D.prevalencePeriod

define "Scan":
  ["Diagnostic Study, Performed": "VSAC; Chest XRay Diagnostic Test"]
  union ["Diagnostic Study, Performed": "Able; CT Scan"]
  union ["Diagnostic Study, Performed": "Able; MRI"]
  union ["Diagnostic Study, Performed": "Able; PET Scan"]
  union ["Diagnostic Study, Performed": "Able; Nuclear Medicine Scan"]

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 3320F":
  /*
   * config_link_id: 3320F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3320F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or not exists("Scan" D
    where D.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 3319F-1P":
  /*
   * config_link_id: 3319F-1P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3319F-1P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception: 3319F-3P":
  /*
   * config_link_id: 3319F-3P
   */
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 3319F-3P"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3319F-8P":
  /*
   * config_link_id: 3319F-8P
   */
  not "Numerator Performance Met: 3320F"
