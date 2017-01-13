// Protype (-CN 01/11/2017)

using QDM

// Able custom value sets

// valueset info store in following format: (key l: value v:) (String,String)

valueset "G9687; MIPS; Hospice Service"
valueset "3046F; Performance Met: 3046F"
valueset "3046f-8P; Performance Met: 3046F-8P"
valueset "3044F; Performance Not Met: 3044F"
valueset "3045; Performance Not Met"
valueset "2.16.840.1.113883.3.464.1003.103.12.1002; Diabetes"  //Note this is the value set for the ICD-10-CM extensional value set—only import ICD-10-CM codes
valueset "2.16.840.1.113883.3.600.1.1579'; Palliative Care"
valueset "2.16.840.1.113762.1.4.1053; Hemoglobin A1C (HbA1c)"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator":
  AgeInYearsAt(start of "Measurement Period") >= 18
  and AgeInYearsAt(start of "Measurement Period") < 75
  and exists([Diagnosis: "Diagnosis of Diabates"] D
    where D.prevalencePeriod overlaps "Measurement Period")
  and exists([Encounter, Performed: "MIPS; 001 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period")
    and E.signingProvider.pqrsProvider = true

define "Denominator Exclusion":
  exists([Intervention, Performed: "VSAC; Palliative Care"] I
    where I.relevantPeriod overlaps "Measurement Period")
  or exists([Intervention, Performed: "MIPS; Hospice Service: G9687"] I
    where I.relevantPeriod overlaps "Measurement Period")

define "Numerator Performance Met: 3046F":
  Last([Laboratory Test, Performed: "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Period").result.value > 9
  or exists([Procedure, Performed: "MIPS; Performance Met: 3046F"] P
    where P.relevantPeriod starts during "Measurement Period")
  )

define "Numerator Performance Met: 3046-8P":
  not exists(Laboratory Test, Performed: "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Period")
  or exists([Procedure, Performed: "MIPS; Performance Met: 3046F-8P"] P
    where P.relevantPeriod starts during "Measurement Period")
  )

define "Numerator Performance Not Met: 3044F":
  Last([Laboratory Test, Performed: "VSAC; HbA1c Laboratory Test"] L
    where L.resultDateTime during "Measurement Period").result.value in Interval[7,9)
  or exists([Procedure, Performed: "MIPS; Performance Not Met: 3044F"] P
    where P.relevantPeriod starts during "Measurement Period")
  )

define "Numerator Performance Not Met: 3045F":
  not "Numerator Performance Met: 3046F"
  and not "Numerator Performance Met: 3046-8P"
  and not "Numerator Performance Not Met: 3044F"
