library HEDIS_CDC5_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: CDC5
 * Year: 2017
 * Version: 2
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Diabetes": '2.16.840.1.113883.3.464.1004.1077'
valueset "HEDIS; Outpatient": '2.16.840.1.113883.3.464.1004.1202'
valueset "HEDIS; Observation": '2.16.840.1.113883.3.464.1004.1191'
valueset "HEDIS; ED": '2.16.840.1.113883.3.464.1004.1086'
valueset "HEDIS; Nonacute Inpatient": '2.16.840.1.113883.3.464.1004.1189'
valueset "HEDIS; Acute Inpatient": '2.16.840.1.113883.3.464.1004.1017'
valueset "HEDIS; Diabetic Retinal Screening": '2.16.840.1.113883.3.464.1004.1078'
valueset "HEDIS; Diabetic Retinal Screening With Eye Care Professional": '2.16.840.1.113883.3.464.1004.1080'
valueset "HEDIS; Diabetic Retinal Screening Negative": '2.16.840.1.113883.3.464.1004.1079'
valueset "HEDIS; Unilateral Eye Enucleation": '2.16.840.1.113883.3.464.1004.1454'
valueset "HEDIS; Unilateral Eye Enucleation Left": '2.16.840.1.113883.3.464.1004.1455'
valueset "HEDIS; Unilateral Eye Enucleation Right": '2.16.840.1.113883.3.464.1004.1455'
valueset "HEDIS; Diabetes Mellitus Without Complications": '2.16.840.1.113883.3.464.1004.1407'
valueset "HEDIS; Diabetes Medications"
valueset "HEDIS; Diabetes Exclusions": '2.16.840.1.113883.3.464.1004.1105'

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'
valueset "VSAC; Retinal or Dilated Eye Exam": '2.16.840.1.113883.3.464.1003.115.12.1088'

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Eye Exam":
  ["Assessment, Performed": "HEDIS; Diabetic Retinal Screening"]
  union ["Assessment, Performed": "VSAC; Retinal or Dilated Eye Exam"]

define "Unilateral Enucleation":
  ["Assessment, Performed": "HEDIS; Unilateral Eye Enucleation"] A
    where A.authorDateTime before end of "Measurement Year"

define "Left and Right Enucleations Exist":
  exists(["Assessment, Performed": "HEDIS; Unilateral Eye Enucleation Left"] A
    where A.authorDateTime before end of "Measurement Year")
  and exists(["Assessment, Performed": "HEDIS; Unilateral Eye Enucleation Right"] A
    where A.authorDateTime before end of "Measurement Year")

define "Two Unilateral Enucleations Exist":
  exists("Unilateral Enucleation" A1
    with "Unilateral Enucleation" A2
      such that A1.authorDateTime 14 days or more after A2.authorDateTime)
  or "Left and Right Enucleations Exist"

define "Denominator":
  "HEDIS CDC1: Denominator"

define "Denominator Exclusion: Diagnosis"
  /*
  * config_link_id: exclusion_1
  */
  "HEDIS CDC1: Denominator Exclusion: Diagnosis"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("Eye Exam" A
    where A.authorDateTime during "Measurement Year"
      and A.signingProvider.specialty in ['Ophthalmology', 'Optometry'])
  or exists("Eye Exam" A
    where A.authorDateTime during [12 months before start of "Measurement Year", start of "Measurement Year"]
      and A.signingProvider.specialty in ['Ophthalmology', 'Optometry']
      and A.result = 'Negative')
  or exists(["Assessment, Performed": "HEDIS; Diabetic Retinal Screening Negative"] A
    where A.authorDateTime during [12 months before start of "Measurement Year", start of "Measurement Year"])
  or exists("Eye Exam" A
    where A.authorDateTime during [12 months before start of "Measurement Year", start of "Measurement Year"]
      and A.signingProvider.specialty in ['Ophthalmology', 'Optometry']
    with ["Diagnosis": "HEDIS; Diabetes Mellitus Without Complications"] D
      such that D.prevalencePeriod starts at A.authorDateTime)
  or exists(["Assessment, Performed": "HEDIS; Diabetic Retinal Screening with Eye Care Professional"] A
    where A.authorDateTime during "Measurement Year")
  or exists ("Unilateral Enucleation" A
    where A.code.modifier in {'50','09950'})
  or "Two Unilateral Enucleations Exist"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Numerator Performance Met"
