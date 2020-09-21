library HEDIS_CIS1_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: CIS1
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS value sets

valueset "MIPS; MIPS Hospice Service"

// HEDIS value sets

valueset "HEDIS; DTaP Vaccine Administered": '2.16.840.1.113883.3.464.1004.1071'
valueset "HEDIS; Inactivated Polio Vaccine (IPV) Administered": '2.16.840.1.113883.3.464.1004.1135'
valueset "HEDIS; Measles, Mumps and Rubella (MMR) Vaccine Administered": '2.16.840.1.113883.3.464.1004.1158'
valueset "HEDIS; Measles/Rubella Vaccine Administered": '2.16.840.1.113883.3.464.1004.1172'
valueset "HEDIS; Mumps Vaccine Administered": '2.16.840.1.113883.3.464.1004.1321'
valueset "HEDIS; Measles Vaccine Administered": '2.16.840.1.113883.3.464.1004.1320'
valueset "HEDIS; Rubella Vaccine Administered": '2.16.840.1.113883.3.464.1004.1322'
valueset "HEDIS; Haemophilus Influenzae Type B (HiB) Vaccine Administered": '2.16.840.1.113883.3.464.1004.1120'
valueset "HEDIS; Hepatitis B Vaccine Administered": '2.16.840.1.113883.3.464.1004.1118'
valueset "HEDIS; Newborn Hepatitis B Vaccine Administered": '2.16.840.1.113883.3.464.1004.1397'
valueset "HEDIS; Varicella Zoster (VZV) Vaccine Administered": '2.16.840.1.113883.3.464.1004.1323'
valueset "HEDIS; Pneumococcal Conjugate Vaccine Administered": '2.16.840.1.113883.3.464.1004.1214'
valueset "HEDIS; Hepatitis A Vaccine Administered": '2.16.840.1.113883.3.464.1004.1318'
valueset "HEDIS; Rotavirus Vaccine (2 Dose Schedule) Administered": '2.16.840.1.113883.3.464.1004.1231'
valueset "HEDIS; Rotavirus Vaccine (3 Dose Schedule) Administered": '2.16.840.1.113883.3.464.1004.1267'
valueset "HEDIS; Influenza Vaccine Administered": '2.16.840.1.113883.3.464.1004.1140'
valueset "HEDIS; Analphylactic Reaction Due to Vaccination": '2.16.840.1.113883.3.464.1004.1024'
valueset "HEDIS; Encephalopathy Due To Vaccination": '2.16.840.1.113883.3.464.1004.1092'
valueset "HEDIS; Vaccine Causing Adverse Effect": '2.16.840.1.113883.3.464.1004.1259'
valueset "HEDIS; Disorders of the Immune System": '2.16.840.1.113883.3.464.1004.1139'
valueset "HEDIS; HIV": '2.16.840.1.113883.3.464.1004.1110'
valueset "HEDIS; HIV Type 2": '2.16.840.1.113883.3.464.1004.1406'
valueset "HEDIS; Malignant Neoplasm of Lymphatic Tissue": '2.16.840.1.113883.3.464.1004.1319'
valueset "HEDIS; Severe Combined Immunodeficiency": '2.16.840.1.113883.3.464.1004.1416'
valueset "HEDIS; Intussusception": '2.16.840.1.113883.3.464.1004.1415'

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// Able value sets

valueset "Able; Neomycin Ingredient"
valueset "Able; Polymyxin B Ingredient"
valueset "Able; Streptomycin Ingredient"
valueset "Able; Baker's Yeast"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "MIPS; MIPS Hospice Service"]
  union ["Intervention, Performed": "VSAC; Palliative Care"]

define "Exclusion for Any Vaccine Exists"
  exists(["Diagnosis": "HEDIS; Analphylactic Reaction Due to Vaccination"] D
    where D.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  and not "CIS 1 Performance Met"
  and not "CIS 2 Performance Met"
  and not "CIS 3 Performance Met"
  and not "CIS 4 Performance Met"
  and not "CIS 5 Performance Met"
  and not "CIS 6 Performance Met"
  and not "CIS 7 Performance Met"
  and not "CIS 8 Performance Met"
  and not "CIS 9 Performance Met"
  and not "CIS 10 Performance Met"

define "DTaP Allergy Exists":
  exists(["Diagnosis": "HEDIS; Encephalopathy Due To Vaccination"] D1
    where D.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
    with ["Diagnosis": "HEDIS; Vaccine Causing Adverse Effect"] D2
      such that D1.prevalencePeriod starts at start of D2.prevalencePeriod
  or exists(["Allergy": "HEDIS; DTaP Vaccine Administered"] A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")

define "Exclusion for DTaP Exists":
  "DTaP Allergy Exists"
  and not "CIS1 Performance Met"

define "Diagnosis for MMR, VZV, and Influenza Exclusion"
  ["Diagnosis": "HEDIS; Disorders of the Immune System"]
  union ["Diagnosis": "HEDIS; HIV"]
  union ["Diagnosis": "HEDIS; HIV Type 2"]
  union ["Diagnosis": "HEDIS; Malignant Neoplasm of Lymphatic Tissue"]

define "MMR Allergy":
  ["Allergy": "HEDIS; Measles, Mumps and Rubella (MMR) Vaccine Administered"]
  union ["Allergy": "HEDIS; Measles/Rubella Vaccine Administered"]
  union ["Allergy": "HEDIS; Measles Vaccine Administered"]
  union ["Allergy": "HEDIS; Mumps Vaccine Administered"]
  union ["Allergy": "HEDIS; Rubella Vaccine Administered"]
  union ["Allergy": "Able; Neomycin Ingredient"]

define "Allergy for MMR Exists":
  exists("Diagnosis for MMR, VZV, and Influenza Exclusion" D
    where D.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  or exists("MMR Allergy" A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")

define "Exclusion for MMR Exists":
  "Allergy for MMR Exists"
  and not "CIS3 Performance Met"

define "Allergy for VZV Exists":
  exists("Diagnosis for MMR, VZV, and Influenza Exclusion" D
    where D.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  or exists(["Allergy": "Able; Neomycin Ingredient"] A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  or exists(["Allergy": "HEDIS: Varicella Zoster (VZV) Vaccine Administered"] A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")

define "Exclusion for VZV Exists":
  "Allergy for VZV Exists"
  and not "CIS6 Performance Met"

define "Allergy for Influenza Exists":
  exists("Diagnosis for MMR, VZV, and Influenza Exclusion" D
    where D.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  or exists(["Allergy": "Able; Neomycin Ingredient"] A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  or exists(["Allergy": "HEDIS: Influenza Vaccine Administered"] A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")

define "Exclusion for Influenza Exists":
  "Allergy for Influenza Exists"
  and not "CIS10 Performance Met"

define "Diagnosis for Rotavirus Exclusion":
  ["Diagnosis": "HEDIS; Severe Combined Immunodeficiency"
  union ["Diagnosis": "HEDIS; Intussusception"]

define "Rotavirus Allergy":
  ["Allergy": "HEDIS; Rotavirus Vaccine (2 Dose Schedule) Administered"]
  union ["Allergy": "HEDIS; Rotavirus Vaccine (3 Dose Schedule) Administered"]

define "Rotavirus Allergy Exists":
  exists("Diagnosis for Rotavirus Exclusion" D
    where D.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  or exists("Rotavirus Allergy" A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")

define "Exclusion for Rotavirus":
  "Rotavirus Allergy Exists"
  and not "CIS9 Performance Met"

define "Allergy for IPV Exclusion"
  ["Allergy": "Able; Neomycin Ingredient"]
  union ["Allergy": "Able; Streptomycin Ingredient"]
  union ["Allergy": "Able; Polymyxin B Ingredient"]
  union ["Allergy": "Able; Inactivated Polio Vaccine (IPV) Administered"]

define "Exclusion for IPV":
  exists("Allergy for IPV Exclusion" A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  amnd not "CIS2 Performance Met"

define "Allergy for Hepatitis B":
    ["Allergy": "Able; Baker's Yeast"]
    union ["Allergy": "HEDIS; Hepatitis B Vaccine Administered"]
    union ["Allergy": "HEDIS; Newborn Hepatitis B Vaccine Administered"]

define "Exclusion for Hepatitis B":
  exists("Allergy for Hepatitis B" A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  amnd not "CIS5 Performance Met"

define "DTaP Procedure":
  ["Procedure, Performed": "HEDIS; DTaP Vaccine Administered"] P
    where P.relevantPeriod starts during ["Patient Characteristic Birthdate" + 42 days, "Patient Characteristic Birthdate" + 2 years]

define "DTaP Medication":
  ["Medication, Administered": "HEDIS; DTaP Vaccine Administered"] M
    where M.authorDateTime during ["Patient Characteristic Birthdate" + 42 days, "Patient Characteristic Birthdate" + 2 years]

// Populations

define "Denominator":
  AgeInYearsAt(end of "Measurement Period") = 2
  and not exists("Hospice" E
    where E.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  "Exclusion for Any Vaccine Exists"
  or "Exclusion for DTaP Exists"
  or "Exclusion for MMR Exists"
  or "Exclusion for VZV Exists"
  or "Exclusion for Influenza Exists"
  or "Exclusion for Rotavirus Exists"
  or "Exclusion for IPV Exists"
  or "Exclusion for Hepatitis B Exists"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  exists("DTaP Procedure" P1
    with "DTaP Procedure" P2
      and "DTaP Procedure" P3
      and "DTaP Procedure" P4
    such that P1.relevantPeriod starts 1 day or more before start of P2.relevantPeriod
      and P2.relevantPeriod starts 1 day or more before start of P3.relevantPeriod
      and P3.relevantPeriod starts 1 day or more before start of P4.relevantPeriod)
  or exists("DTaP Medication" M1
    with "DTaP Medication" M2
      and "DTaP Medication" M3
      and "DTaP Medication" M4
    such that M1.authorDateTime 1 day or more before M2.authorDateTime
      and M2.authorDateTime 1 day or more before M3.authorDateTime
      and M3.authorDateTime 1 day or more before M4.authorDateTime)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
