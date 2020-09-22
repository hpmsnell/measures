library HEDIS_CIS14_2017 version '1'

/*
 *
 * Source: HEDIS
 * ID: CIS14
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
valueset "HEDIS Varicella Zoster": '2.16.840.1.113883.3.464.1004.1258'
valueset "HEDIS; Hepatitis B": '2.16.840.1.113883.3.464.1004.1266'

// VSAC value sets

valueset "VSAC; Palliative Care": '2.16.840.1.113883.3.600.1.1579'

// Able value sets

valueset "Able; Neomycin Ingredient"
valueset "Able; Polymyxin B Ingredient"
valueset "Able; Streptomycin Ingredient"
valueset "Able; Baker's Yeast"

parameter "Measurement Period" Interval<DateTime>

context Patient

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
  "CIS1 Numerator Performance Met"
  and "CIS2 Numerator Performance Met"
  and "CIS3 Numerator Performance Met"
  and "CIS4 Numerator Performance Met"
  and "CIS5 Numerator Performance Met"
  and "CIS6 Numerator Performance Met"
  and "CIS7 Numerator Performance Met"
  and "CIS9 Numerator Performance Met"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
