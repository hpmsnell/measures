library MIPS_441_2020 version '1'

/*
 * Source: MIPS
 * ID: 441
 * Year: 2020
 * Written By: Patrick Clark
 *
  */

using QDM

// MIPS Value Sets

valueset "MIPS; MIPS 441 Encounter"
valueset "MIPS; MIPS 441 CAD"
valueset "MIPS; MIPS 441 AMI"
valueset "MIPS; MIPS 441 PCI"
valueset "MIPS; MIPS 441 CABG"
valueset "MIPS; ESRD"
valueset "MIPS; MIPS Hospice Exclusion"
valueset "MIPS; Performance Met: G9788"
valueset "MIPS; Performance Met: G9791"
valueset "MIPS; Performance Met: G9793"
valueset "MIPS; Performance Met: G9796"
valueset "MIPS; Performance Met: G2128"
valueset "MIPS; Performance Met: G9940"
valueset "MIPS; Denominator Exception: G9789"
valueset "MIPS; Denominator Exception: G2129"
valueset "MIPS; Performance Not Met: G9790"
valueset "MIPS; Performance Not Met: G9792"
valueset "MIPS; Performance Not Met: G9795"
valueset "MIPS; Performance Not Met: G9797"

// VSAC Value Sets

valueset "VSAC; Palliative Care"
valueset "VSAC; Systolic Blood Pressure"
valueset "VSAC; Diastolic Blood Pressure"
valueset "VSAC; Tobacco Non-User"
valueset "VSAC; Tobacco User"
valueset "VSAC; Aspirin and Other Antiplatelets"
valueset "VSAC; Gastrointestinal Hemorrhage"
valueset "VSAC; Anticoagulant Medications"
valueset "VSAC; Gastric Bypass Surgery"
valueset "VSAC; Low intensity statin therapy"
valueset "VSAC; Moderate intensity statin therapy"
valueset "VSAC; High intensity statin therapy"
valueset "VSAC; Pregnancy Dx"
valueset "VSAC; ESRD Monthly Outpatient Services"
valueset "VSAC; Kidney Transplant"

// HEDIS value sets

valueset "HEDIS; Muscular Pain and Disease"

parameter "Measurement Period" Interval<DateTime>

context Patient

// Denominator components

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 441 Encounter"] E
    where E.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"]
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and AgeInYearsAt(start of E.relevantPeriod) < 75
      and E.signingProvider.hasMeasureMembership = true

define "Eligible Procedure":
  ["Procedure, Performed": "MIPS 441 AMI"]
  union ["Procedure, Performed": "MIPS 441 PCI"]
  union ["Procedure, Performed": "MIPS 441 CABG"]

define "Eligible Condition or Procedure Exists":
  exists(["Diagnosis": "MIPS 441 CAD"] D
    where D.prevalencePeriod overlaps "Measurement Period")
  exists("Eligible Procedure" P
    where P.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])

// Numerator components

define "Normal Blood Pressure Exists":
  Last(["Physical Exam, Performed": "VSAC; Diastolic Blood Pressure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
      sort by P.relevantPeriod asc
      return P.result) <= 90
  and Last(["Physical Exam, Performed": "VSAC; Systolic Blood Pressure"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod
      sort by P.relevantPeriod asc
      return P.result) <= 140

define "Numerator Component 1":
  exists(["Procedure, Performed": "MIPS; Performance Met: G9788"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "Normal Blood Pressure Exists"

define "Numerator Component 2":
  exists(["Procedure, Performed": "MIPS; Performance Met: G9791"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Assessment, Performed": "VSAC; Tobacco Non-User"] A1
    where A1.authorDateTime during "Measurement Period"
    without ["Assessment, Performed": "VSAC; Tobacco User"] A2
      such that A2.authorDateTime during "Measurement Period"
      and A2.authorDateTime after A1.authorDateTime)

define "Numerator Component 3":
  exists(["Procedure, Performed": "MIPS; Performance Met: G9793"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; Performance Met: G2128"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Medication": "VSAC; Aspirin and Other Antiplatelets"] M
    where M.relevantPeriod overlaps "Measurement Period")
  or exists(["Diagnosis": "VSAC; Gastrointestinal Hemorrhage"] D
    where D.prevalencePeriod starts before end of "Measurement Period")
  or exists(["Procedure, Performed": "VSAC; Gastric Bypass Surgery"] P
    where P.relevantPeriod starts before end of "Measurement Period")
  or exists(["Medication": "VSAC; Anticoagulant Medications"] M
    where M.relevantPeriod overlaps "Measurement Period")

define "Statin":
  ["Medication": "VSAC; Low intensity statin therapy"]
  union ["Medication": "VSAC; Moderate intensity statin therapy"]
  union ["Medication": "VSAC; High intensity statin therapy"]

define "Numerator Component 4":
  exists(["Procedure, Performed": "MIPS; Performance Met: G9796"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; Performance Met: G9940"] P
    where P.relevantPeriod starts during "Measurement Period")
  or exists("Statin" M
    where M.relevantPeriod overlaps "Measurement Period")
  or exists(["Diagnosis": "VSAC; Pregnancy Dx"] D
    where D.prevalencePeriod overlaps [24 months before end of "Measurement Period", end of "Measurement Period"])
  or exists(["Diagnosis": "MIPS; ESRD"] D
    where D.prevalencePeriod overlaps [24 months before end of "Measurement Period", end of "Measurement Period"])
  or exists(["Procedure, Performed": "VSAC; ESRD Monthly Outpatient Services"] P
    where P.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
  or exists(["Procedure, Performed": "VSAC; Kidney Transplant"] P
    where P.relevantPeriod starts during [24 months before end of "Measurement Period", end of "Measurement Period"])
  or exists(["Diagnosis": "VSAC; Cirrhosis"] D
    where D.prevalencePeriod overlaps [24 months before end of "Measurement Period", end of "Measurement Period"])
  or exists(["Diagnosis": "HEDIS; Muscular Pain and Disease"] D
    where D.prevalencePeriod overlaps [24 months before end of "Measurement Period", end of "Measurement Period"])

// Population

define "Denominator":
  count("Denominator Encounter") >= 2
  and exists("Denominator Encounter" E
    where E.relevantPeriod starts during "Measurement Year")
  and "Eligible Condition or Procedure Exists"

define "Denominator Exclusion: BP Inpatient Stay":
   exists(["Procedure, Performed": "MIPS; Denominator Exception: G9789"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: BP not taken Outpatient Visit"
  or exists(["Procedure, Performed": "MIPS; Denominator Exception: G2129"] P2
    where P2.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: Hospice":
/*
 * config_link_id: exclusion_1
 */
exists(["Intervention, Performed": "MIPS; MIPS Hospice Service"] I
  where I.relevantPeriod starts during "Denominator Period")
or exists(["Intervention, Performed": "VSAC; Palliative Care"] I
  where I.relevantPeriod starts during "Denominator Period")

define "Numerator Performance Met":
  /*
   * config_link_id:
   */
  "Numerator Component 1"
  and "Numerator Component 2"
  and "Numerator Component 3"
  and "Numerator Component 4"

define "Numerator Performance Not Met":
  /*
   * config_link_id: G8785
   */
  not "Denominator Exclusion: BP Inpatient Stay"
  and not "Denominator Exclusion: BP not taken Outpatient Visit"
  and not "Denominator Exclusion: Hospice"
  and not "Numerator Performance Met"
