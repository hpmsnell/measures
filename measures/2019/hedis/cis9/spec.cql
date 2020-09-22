library HEDIS_CIS9_2019 version '1'

/*
 *
 * Source: HEDIS
 * ID: CIS9
 * Year: 2019
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// HEDIS value sets

valueset "HEDIS; Hospice": '2.16.840.1.113883.3.464.1004.1418'
valueset "HEDIS; DTaP Immunization": '2.16.840.1.113883.3.464.1004.1744'
valueset "HEDIS; DTaP Vaccine Procedure": '2.16.840.1.113883.3.464.1004.1745'
valueset "HEDIS; Inactivated Polio Vaccine (IPV) Immunization": '2.16.840.1.113883.3.464.1004.1765'
valueset "HEDIS; Inactivated Polio Vaccine (IPV) Procedure": '2.16.840.1.113883.3.464.1004.1766'
valueset "HEDIS; Measles, Mumps and Rubella (MMR) immunization": '2.16.840.1.113883.3.464.1004.1773'
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
valueset "HEDIS; Haemophilus Influenzae Type B (HiB) Vaccine Procedure": ' 2.16.840.1.113883.3.464.1004.1753'
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

define “2-Dose Rotavirus Immunization or Procedure"
  ((["Immunization, Administered": "Rotavirus (2 Dose Schedule) Immunization"]
  union ["Procedure, Performed": "Rotavirus Vaccine (2 Dose Schedule) Procedure”])2RotaVacc
  where 2RotaVacc.relevantDatetime during Interval["Patient Characteristic Birthdate", "Patient Characteristic Birthdate" + 2 years])

define “3-Dose Rotavirus Immunization or Procedure"
  ((["Immunization, Administered": "Rotavirus (3 Dose Schedule) Immunization"]
  union ["Procedure, Performed": "Rotavirus Vaccine (3 Dose Schedule) Procedure”])3RotaVacc
  where 3RotaVacc.relevantDatetime during Interval["Patient Characteristic Birthdate", "Patient Characteristic Birthdate" + 2 years])



define "Two 2-Dose Rotavirus Immunizations or Procedures Exist":
  exists("2-Dose Rotavirus Immunization or Procedure" 2RotaVacc1
    with "2-Dose Rotavirus Immunization or Procedure" 2RotaVacc2
    such that 2RotaVacc1.relevantDatetime starts 1 day or more before start of 2RotaVacc2.relevantDatetime)


define "Three 3-Dose Rotavirus Immunizations or Procedures Exist":
  exists("3-Dose Rotavirus Immunization or Procedure" 3RotaVacc1
    with "3-Dose Rotavirus Immunization or Procedure" 3RotaVacc2
      and "3-Dose Rotavirus Immunization or Procedure" 3RotaVacc3
    such that 3RotaVacc1.relevantDatetime starts 1 day or more before start of 3RotaVacc2.relevantDatetime
      and 3RotaVacc2.relevantDatetime starts 1 day or more before start of 3RotaVacc3.relevantDatetime)

define "Two 3-Dose Rotavirus Immunizations or Procedures Exist":
  exists("3-Dose Rotavirus Immunization or Procedure" 3RotaVacc1
    with "3-Dose Rotavirus Immunization or Procedure" 3RotaVacc2
    such that P1.relevantDatetime starts 1 day or more before start of P2.relevantDatetime)

define "One 2-Dose Rotavirus and Two 3-Dose Rotavirus Immunizations or Procedures Exist":
  "2-Dose Rotavirus Immunization or Procedure"
  and "Two 3-Dose Rotavirus Immunizations or Procedures Exist"

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
  "Two 2-Dose Rotavirus Immunizations or Procedures Exist"
  or "Three 3-Dose Rotavirus Immunizations or Procedures Exist"
  or "One 2-Dose Rotavirus and Two 3-Dose Rotavirus Immunizations or Procedures Exist"

define "Numerator Performance Not Met":
  /*
   * config_link_id: performance_not_met
   */
  not "Denominator Exclusion"
  and not "Numerator Performance Met"
