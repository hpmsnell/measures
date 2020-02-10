library HEDIS_CIS1_2020 version '1'

/*
 *
 * Source: HEDIS
 * ID: CIS1
 * Year: 2020
 * Version: 1
 * Author: Chana West
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; DTaP Immunization": '2.16.840.1.113883.3.464.1004.1744'
valueset "HEDIS; DTaP Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1745'
valueset "HEDIS; Inactivated Polio Vaccine (IPV) Immunization": '2.16.840.1.113883.3.464.1004.1765'
valueset "HEDIS; Inactivated Polio Vaccine (IPV) Procedure": '2.16.840.1.113883.3.464.1004.1766'
valueset "HEDIS; Measles, Mumps and Rubella (MMR) Immunization": '2.16.840.1.113883.3.464.1004.1773'
valueset "HEDIS; Measles, Mumps and Rubella (MMR) Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1774'
valueset "HEDIS; Mumps": '2.16.840.1.113883.3.464.1004.1181'
valueset "HEDIS; Mumps Immunization": '2.16.840.1.113883.3.464.1004.1779'
valueset "HEDIS; Mumps Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1780'
valueset "HEDIS; Measles Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1772'
valueset "HEDIS; Measles": '2.16.840.1.113883.3.464.1004.1171'
valueset "HEDIS; Measles Immunization": '2.16.840.1.113883.3.464.1004.1771'
valueset "HEDIS; Rubella": '2.16.840.1.113883.3.464.1004.1232'
valueset "HEDIS; Rubella Immunization": '2.16.840.1.113883.3.464.1004.1789'
valueset "HEDIS; Rubella Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1790'
valueset "HEDIS; Measles Rubella Immunization": '2.16.840.1.113883.3.464.1004.1775'
valueset "HEDIS; Measles Rubella Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1776'
valueset "HEDIS; Haemophilus Influenzae Type B (HiB) Immunization": '2.16.840.1.113883.3.464.1004.1753'
valueset "HEDIS; Haemophilus Influenzae Type B (HiB) Vaccine Procedure": ' .16.840.1.113883.3.464.1004.1753'
valueset "HEDIS; Hepatitis B": '2.16.840.1.113883.3.464.1004.1266'
valueset "HEDIS; Hepatitis B Immunization": '2.16.840.1.113883.3.464.1004.1759'
valueset "HEDIS; Hepatitis B Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1760'
valueset "HEDIS; Newborn Hepatitis B Vaccine Administered": '2.16.840.1.113883.3.464.1004.1397'
valueset "HEDIS; Varicella Zoster": '2.16.840.1.113883.3.464.1004.1258'
valueset "HEDIS; Varicella Zoster (VZV) Immunization": '2.16.840.1.113883.3.464.1004.1793'
valueset "HEDIS; Varicella Zoster (VZV) Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1794'
valueset "HEDIS; Pneumococcal Conjugate Immunization": '2.16.840.1.113883.3.464.1004.1781'
valueset "HEDIS; Pneumococcal Conjugate Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1782'
valueset "HEDIS; Hepatitis A": '2.16.840.1.113883.3.464.1004.1117'
valueset "HEDIS; Hepatitis A Immunization": '2.16.840.1.113883.3.464.1004.1757'
valueset "HEDIS; Hepatitis A Procedure": '2.16.840.1.113883.3.464.1004.1758
valueset "HEDIS; Rotavirus Vaccine (2 Dose Schedule) Procedure": '2.16.840.1.113883.3.464.1004.1787'
valueset "HEDIS; Rotavirus (2 Dose Schedule) Immunization": '2.16.840.1.113883.3.464.1004.1785'
valueset "HEDIS; Rotavirus (3 Dose Schedule) Immunization": '2.16.840.1.113883.3.464.1004.1786'
valueset "HEDIS; Rotavirus Vaccine (3 Dose Schedule) Procedure": '2.16.840.1.113883.3.464.1004.1788'
valueset "HEDIS; Influenza Immunization": '2.16.840.1.113883.3.464.1004.1767'
valueset "HEDIS; Influenza Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1768'
valueset "HEDIS; Influenza Virus LAIV Immunization": '2.16.840.1.113883.3.464.1004.1974'
valueset "HEDIS; Influenza Virus LAIV Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1973'
valueset "HEDIS; Analphylactic Reaction Due to Vaccination": '2.16.840.1.113883.3.464.1004.1024'
valueset "HEDIS; Encephalopathy Due To Vaccination": '2.16.840.1.113883.3.464.1004.1092'
valueset "HEDIS; Vaccine Causing Adverse Effect": '2.16.840.1.113883.3.464.1004.1259'
valueset "HEDIS; Disorders of the Immune System": '2.16.840.1.113883.3.464.1004.1139'
valueset "HEDIS; HIV": '2.16.840.1.113883.3.464.1004.1110'
valueset "HEDIS; HIV Type 2": '2.16.840.1.113883.3.464.1004.1406'
valueset "HEDIS; Malignant Neoplasm of Lymphatic Tissue": '2.16.840.1.113883.3.464.1004.1319'
valueset "HEDIS; Severe Combined Immunodeficiency": '2.16.840.1.113883.3.464.1004.1416'
valueset "HEDIS; Intussusception": '2.16.840.1.113883.3.464.1004.1415'

// Able value sets

valueset "Able; Neomycin Ingredient"
valueset "Able; Polymyxin B Ingredient"
valueset "Able; Streptomycin Ingredient"
valueset "Able; Baker's Yeast"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Hospice":
  ["Intervention, Performed": "HEDIS; Hospice"]

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
  or exists(["Allergy": "HEDIS; DTaP Immunization"] A
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
  ["Allergy": "HEDIS; Measles, Mumps and Rubella (MMR) Immunization"]
  union ["Allergy": "HEDIS; Measles Rubella Immunization"]
  union ["Allergy": "HEDIS; Measles Immunization"]
  union ["Allergy": "HEDIS; Mumps Immunization"]
  union ["Allergy": "HEDIS; Rubella Immunization"]
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
  or exists(["Allergy": "HEDIS: Varicella Zoster (VZV) Immunization"] A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")

define "Exclusion for VZV Exists":
  "Allergy for VZV Exists"
  and not "CIS6 Performance Met"

define "Allergy for Influenza Exists":
  exists("Diagnosis for MMR, VZV, and Influenza Exclusion" D
    where D.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  or exists(["Allergy": "Able; Neomycin Ingredient"] A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  or exists(["Allergy": "HEDIS: Influenza Immunization"] A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  or exists(["Allergy": "HEDIS: Influenza Virus LAIV Immunization"] A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")

define "Exclusion for Influenza Exists":
  "Allergy for Influenza Exists"
  and not "CIS10 Performance Met"

define "Diagnosis for Rotavirus Exclusion":
  ["Diagnosis": "HEDIS; Severe Combined Immunodeficiency"
  union ["Diagnosis": "HEDIS; Intussusception"]

define "Rotavirus Allergy":
  ["Allergy": "HEDIS; Rotavirus Vaccine (2 Dose Schedule) Immunization"]
  union ["Allergy": "HEDIS; Rotavirus Vaccine (3 Dose Schedule) Immunization"]

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
  union ["Allergy": "Able; Inactivated Polio Vaccine (IPV) Immunization"]

define "Exclusion for IPV":
  exists("Allergy for IPV Exclusion" A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  amnd not "CIS2 Performance Met"

define "Allergy for Hepatitis B":
    ["Allergy": "Able; Baker's Yeast"]
    union ["Allergy": "HEDIS; Hepatitis B Vaccine Immunization"]
    union ["Allergy": "HEDIS; Newborn Hepatitis B Vaccine Administered"]

define "Exclusion for Hepatitis B":
  exists("Allergy for Hepatitis B" A
    where A.prevalencePeriod starts on or before 2 years after "Patient Characteristic Birthdate")
  amnd not "CIS5 Performance Met"



define "DTap Immunizations or Procedures"
  ((["Immunization, Administered": "DTaP Immunization"]
  union ["Procedure, Performed": "DTaP Vaccine Procedure"])DTaPVacc
  where DTaPVacc.relevantDatetime during Interval["Patient Characteristic Birthdate" + 42 days, "Patient Characteristic Birthdate" + 2 year])

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
  exists("DTaP Immunizations or Procedures" DTaPVacc1
    with "DTaP Immunizations or Procedures" DTaPVacc2
      and "DTaP Immunizations or Procedures" DTaPVacc3
      and "DTaP Immunizations or Procedures" DTaPVacc4
    such that DTaPVacc1.relevantDatetime starts 1 day or more before start of DTaPVacc2.relevantDatetime
      and DTaPVacc2.relevantDatetime starts 1 day or more before start of DTaPVacc3.relevantDatetime
      and DTaPVacc3.relevantDatetime starts 1 day or more before start of DTaPVacc4.relevantDatetime)

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
