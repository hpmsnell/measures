library HEDIS_CIS9_2018 version '1'

/*
 *
 * Source: HEDIS
 * ID: CIS9
 * Year: 2018
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

define "2-Dose Rotavirus Procedure":
  ["Procedure, Performed": "HEDIS; Rotavirus Vaccine (2 Dose Schedule) Administered"] P
    where P.relevantPeriod starts on or before "Patient Characteristic Birthdate" + 2 years

define "2-Dose Rotavirus Medication":
  ["Medication, Administered": "HEDIS; Rotavirus Vaccine (2 Dose Schedule) Administered"] M
    where M.authorDateTime on or before "Patient Characteristic Birthdate" + 2 years

define "3-Dose Rotavirus Procedure":
  ["Procedure, Performed": "HEDIS; Rotavirus Vaccine (3 Dose Schedule) Administered"] P
    where P.relevantPeriod starts on or before "Patient Characteristic Birthdate" + 2 years

define "3-Dose Rotavirus Medication":
  ["Medication, Administered": "HEDIS; Rotavirus Vaccine (3 Dose Schedule) Administered"] M
    where M.authorDateTime on or before "Patient Characteristic Birthdate" + 2 years

define "2 2-Dose Rotavirus Procedures Exist":
  exists("2-Dose Rotavirus Procedure" P1
    with "2-Dose Rotavirus Procedure" P2
    such that P1.relevantPeriod starts 1 day or more before start of P2.relevantPeriod)

define "2 2-Dose Rotavirus Medications Exist":
  exists("2-Dose Rotavirus Medication" M1
    with "2-Dose Rotavirus Medication" M2
    such that M1.authorDateTime 1 day or more before M2.authorDateTime)

define "3 3-Dose Rotavirus Procedures Exist":
  exists("3-Dose Rotavirus Procedure" P1
    with "3-Dose Rotavirus Procedure" P2
      and "3-Dose Rotavirus Procedure" P3
    such that P1.relevantPeriod starts 1 day or more before start of P2.relevantPeriod
      and P2.relevantPeriod starts 1 day or more before start of P3.relevantPeriod)

define "3 3-Dose Rotavirus Medications Exist":
  exists("3-Dose Rotavirus Medication" M1
    with "3-Dose Rotavirus Medication" M2
      and "3-Dose Rotavirus Medication" M3
    such that M1.authorDateTime 1 day or more before M2.authorDateTime
      and M2.authorDateTime 1 day or more before M3.authorDateTime)

define "2 3-Dose Rotavirus Procedures Exist":
  exists("3-Dose Rotavirus Procedure" P1
    with "3-Dose Rotavirus Procedure" P2
    such that P1.relevantPeriod starts 1 day or more before start of P2.relevantPeriod)

define "2 3-Dose Rotavirus Medications Exist":
  exists("3-Dose Rotavirus Medication" M1
    with "3-Dose Rotavirus Medication" M2
    such that M1.authorDateTime 1 day or more before M2.authorDateTime)

define "1 2-Dose Rotavirus Exists":
  exists("2-Dose Rotavirus Procedure")
  or exists("2-Dose Rotavirus Medication")

define "2 3-Dose Rotavirus Exist":
  "2 3-Dose Rotavirus Procedures Exist"
  or "2 3-Dose Rotavirus Medications Exist"

define "1 2-Dose Rotavirus and 2 3-Dose Rotavirus Exist":
  "1 2-Dose Rotavirus Exists"
  and "2 3-Dose Rotavirus Exist"

// Populations

define "Denominator":
  "CIS1 Denominator"

define "Denominator Exclusion":
  /*
   * config_link_id: exclusion_1
   */
  "CIS 1 Denominator Exclusion"

define "Numerator Performance Met":
  /*
   * config_link_id: performance_met
   */
  "2 2-Dose Rotavirus Procedures Exist"
  or "2 2-Dose Rotavirus Medications Exist"
  or "3 3-Dose Rotavirus Procedures Exist"
  or "3 3-Dose Rotavirus Medications Exist"
  or "1 2-Dose Rotavirus and 2 3-Dose Rotavirus Exist"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
