library MIPS_126_2017 version '1'

/*
 * Source: MIPS
 * ID: 126
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 126 Encounter"
valueset "MIPS; MIPS 126 Diabetes"
valueset "MIPS; Performance Met: G8404"
valueset "MIPS; Performance Not Met: G8405"

// Able value sets

valueset "Able; Bilateral Amputee"
valueset "Able; Left Foot Amputee"
valueset "Able; Right Foot Amputee"
valueset "Able; Cognitive and Psychiatric Disorders Indicative of Impaired Cognition"
valueset "Able; Monofilament Exam"
valueset "Able; Foot Vibration Exam"
valueset "Able; Ankle Reflex Exam"
valueset "Able; Foot Pin Prick Exam"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 126 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and not E.code.modifier in {'GQ', 'GT'}
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with ["Diagnosis": "MIPS; MIPS 126 Diabetes"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Bilateral Amputation Exists":
  exists(["Diagnosis": "Able; Bilateral Amputee"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "Able; Bilateral Amputee"] P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Left Foot Amputation Exist":
  exists(["Diagnosis": "Able; Left Foot Amputee"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  and exists(["Procedure, Performed": "Able; Left Foot Amputee"] P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Right Foot Amputation Exist":
  exists(["Diagnosis": "Able; Right Foot Amputee"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  and exists(["Procedure, Performed": "Able; Right Foot Amputee"] P
    where P.relevantPeriod starts before end of "Measurement Period")

define "Two Unilateral Amputations Exist":
  "Left Foot Amputation Exists"
  and "Right Foot Amputation Exists"

define "Other Neurological Exam":
  ["Procedure, Performed": "Able; Foot Vibration Exam"]
  union ["Procedure, Performed": "Able; Ankle Reflex Exam"]
  union ["Procedure, Performed": "Able; Foot Pin Prick Exam"]

define "Neurological Exam Exists"
  exists(["Procedure, Performed": "Able; Monofilament Exam"] P
    where P.relevantPeriod starts during "Measurement Period")
  and exists("Other Neurological Exam" P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator":
  exists("Denominator Encounter")

define "Denominator Exclusion: Bilateral Amputee":
  /*
   * config_link_id: exclusion_1
   */
  "Bilateral Amputation Exists"
  or "Two Unilateral Amputations Exist"

define "Denominator Exclusion: Cognitive Impairment":
  /*
   * config_link_id: exclusion_2
   */
  exists(["Diagnosis": "Able; Cognitive and Psychiatric Disorders Indicative of Impaired Cognition"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met: G8404":
  /*
   * config_link_id: G8404
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G8404"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Neurological Exam Exists"

define "Numerator Performance Not Met: G8405":
  /*
   * config_link_id: G8405
   */
  not "Denominator Exclusion: Bilateral Amputee"
  and not "Denominator Exclusion: Cognitive Impairment"
  and not "Numerator Performance Met: G8404"
