library MIPS_052_2018 version '1'

/*
 * Source: MIPS
 * ID: 052
 * Year: 2018
 * Version: 1
 */

using QDM

// Able value sets

valueset "Able; Long-Acting Inhaled Bronchodilator"

// MIPS value sets

valueset "MIPS; MIPS 052 Encounter"
valueset "MIPS; COPD"
valueset "MIPS; FEV1/FVC < 70%, FEV1 < 60%, COPD Symptoms"
valueset "MIPS; Denominator Exception: G9696"
valueset "MIPS; Denominator Exception: G9697"
valueset "MIPS; Denominator Exception: G9698"
valueset "MIPS; Performance Met: G9695"
valueset "MIPS; Performance Not Met: G9699"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 052 Encounter"] E
      where E.relevantPeriod starts during "Measurement Period"
        and AgeInYearsAt(start of E.relevantPeriod) >= 18
        and not E.code.modifier in {'GQ','GT','95'}
        and not E.placeOfService in {'02'}
        and E.signingProvider.hasMeasureMembership = true
      with ["Diagnosis": "MIPS; COPD"] D
        such that D.prevalencePeriod overlaps E.relevantPeriod

define "Denominator":
  exists("Denominator Encounter")
  and exists(["Assessment, Performed": "MIPS; FEV1/FVC < 70%, FEV1 < 60%, COPD Symptoms"] A
    where A.authorDateTime during "Measurement Period")

define "Numerator Performance Met: G9695":
  /*
   * config_link_id: G9695
   */
 exists(["Procedure, Performed": "MIPS; Performance Met: G9695"] P
   where P.relevantPeriod starts during "Measurement Period")
  or exists (["Medication": "Able; Long-Acting Bronchodilator"] M
    where M.relevantPeriod overlaps "Measurement Period")

define "Denominator Exception 1: G9696":
/*
 * config_link_id: G9696
 */
  exists (["Procedure, Performed": "MIPS; Denominator Exception: G9696"] P
    with ["Encounter, Performed": "MIPS; MIPS 052 Encounter"] E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception 5: G9697"
/*
* config_link_id: G9697
*/
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9697"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Denominator Exception 6: G9698":
/*
* config_link_id:  G9698
*/
  exists(["Procedure, Performed": "MIPS; Denominator Exception: G9698"] P
    with "Denominator Encounter" E
      such that P.relevantPeriod starts during E.relevantPeriod

define "Numerator Performance Not Met: G9699":
  /*
   * config_link_id: G9699
   */
  not "Numerator Performance Met: G9695"
  and not "Denominator Exception 1: G9696"
  and not "Denominator Exception 2: G9697"
  and not "Denominator Exception 3: G9698"
