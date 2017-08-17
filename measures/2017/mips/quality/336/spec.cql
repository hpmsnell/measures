library MIPS_336_2017 version '1'

/*
 *
 * Source: MIPS
 * ID: 336
 * Year: 2017
 * Version: 1
 * Written by: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS 336 Procedure"
valueset "MIPS; Performance Met: G9357"
valueset "MIPS; Performance Not Met: G9358"

// VSAC value sets

valueset "VSAC; Adult Depression Screening": '2.16.840.1.113883.3.600.431'
valueset "VSAC; Adolescent Depression Screening": '2.16.840.1.113883.3.600.426'
valueset "VSAC; Maternal Post Partum Depression Screening": '2.16.840.1.113883.3.464.1003.111.12.1014'
valueset "VSAC; PHQ-9 Tool": '2.16.840.1.113883.3.67.1.101.11.723'
valueset "VSAC; Procedures Involving Contraceptive Devices": '2.16.840.1.113883.3.464.1003.111.12.1010'
valueset "VSAC; Contraceptive Medications": '2.16.840.1.113883.3.464.1003.196.12.1080'

// Able value sets

valueset "Able; Breast Feeding Finding"
valueset "Able; Family Planning"
valueset "Able; Gestational Diabetes": '2.16.840.1.113883.3.464.1003.103.12.1010'
valueset "Able; Glucose Lab Test": '2.16.840.1.113762.1.4.1045.134'

parameter "Measurement Period" Interval<DateTime>

context Patient

// Post-partum care components

define "Depression Screening":
  ["Procedure, Performed": "VSAC; Adult Depression Screening"]
  union ["Procedure, Performed": "VSAC; Adolescent Depression Screening"]
  union ["Procedure, Performed": "VSAC; Maternal Post Partum Depression Screening"]
  union ["Procedure, Performed": "VSAC; PHQ-9 Tool"]

define "Family Planning Procedure":
  ["Procedure, Performed": "VSAC; Procedures Involving Contraceptive Devices"]
  union ["Procedure, Performed": "Able; Family Planning"]

// Post-partum care components exist

define "Breast Feeding Evaluation Exists":
  exists(["Diagnosis": "Able; Breast Feeding Finding"] D
    with "Denominator Procedure" P
      such that D.prevalencePeriod starts 56 days or less after start of P.relevantPeriod)

define "Depression Screening Exists":
  exists("Depression Screening" P1
    with "Denominator Procedure" P2
      such that P1.relevantPeriod starts 56 days or less after start of P2.relevantPeriod)

define "Glucose Screening Exists if Diabetic":
  exists(["Laboratory Test, Performed": "Able; Glucose Lab Test"] L
    with "Denominator Procedure" P
      such that L.resultDateTime 56 days or less after start of P.relevantPeriod)
  or not exists(["Diagnosis": "Able; Gestational Diabetes"] D
    with "Denominator Procedure" P
      such that D.prevalencePeriod starts during or 9 months or less before start of P.relevantPeriod)

define "Family Planning Exists":
  exists("Family Planning Procedure" P1
    with "Denominator Procedure" P2
      such that P1.relevantPeriod starts 56 days or less after start of P2.relevantPeriod)
  or exists(["Medication": "VSAC; Contraceptive Medications"] M
    with "Denominator Procedure P
      such that M.relevantPeriod starts 56 days or less after start of P.relevantPeriod)

define "Post-Partum Care Exists"
  "Breast Feeding Evaluation Exists"
  and "Depression Screening Exists"
  and "Glucose Screening Exists if Diabetic"
  and "Family Planning Exists"

define "Denominator Procedure":
  ["Procedure, Performed": "MIPS; MIPS 336 Procedure"] P
    where P.relevantPeriod starts during "Measurement Period"
      and P.signingProvider.hasMeasureMembership = true

define "Denominator":
  exists("Denominator Procedure")

define "Numerator Performance Met: G9357":
  /*
   * config_link_id: G9357
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: G9357"] P
    where D.prevalencePeriod starts before end of "Measurement Year")
  or "Post-Partum Care Exists"

define "Numerator Performance Not Met: G9358":
  /*
   * config_link_id: G9358
   */
  not "Numerator Performance Met: G9357"
