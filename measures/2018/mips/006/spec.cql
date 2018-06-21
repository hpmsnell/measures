library MIPS_006_2018 version '1'

/*
 * Source: MIPS
 * ID: 006
 * Year: 2018
 * Version: 1
 */

using QDM

// Able value sets

valueset "Able; Other Thienopyridine Agent"
valueset "Able; Aspirin and Clopidogrel"

// MIPS value sets

valueset "MIPS; MIPS 006 Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Coronary Artery Disease (CAD)"
valueset "MIPS; Denominator Exception: 4086F-1P"
valueset "MIPS; Denominator Exception: 4086F-2P"
valueset "MIPS; Denominator Exception: 4086F-3P"
valueset "MIPS; Performance Met: 4086F"
valueset "MIPS; Performance Not Met: 4086F-8P"


// VSAC value sets

valueset "VSAC; Thrombocytopenia": '2.16.840.1.113762.1.4.1045.45'
valueset "VSAC; Warfarin": '2.16.840.1.113883.3.117.1.7.1.232'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Encounter":
  ["Encounter, Performed": "MIPS; MIPS 006 Encounter"] E
    where E.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and not E.code.modifier "MIPS; Telemedicine Modifier"
      and E.signingProvider.hasMeasureMembership = true
      and not E.code.modifier in {'GQ','GT','95'}
      and not E.placeOfService in {'02'}
    with ["Diagnosis": "MIPS; Coronary Artery Disease (CAD)"] D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "Numerator Performance Met: 4086F":
  /*
   * config_link_id: 4086F
   */
  exists (["Medication": "Able; Aspirin and Clopidogrel"] M
    where M.relevantPeriod overlaps "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; Performance Met: 4086F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exception 1: 4086F-1P":
/*
 * config_link_id: denominator_exception_1
 * Exception 1: patient excepted because of non-specific reason
 */
  exists (["Procedure, Performed": "MIPS; Denominator Exception: 4086-1P"] P
    where M.relevantPeriod starts during of "Measurement Period")
  or exists (["Allergy/Intolerance": "Able; Aspirin and Clopidogrel"] A
    where A.prevalencePeriod overlaps "Measurement Period")
  or exists(["Medication": "Able; Other Thienopyridine Agent"] M
    where M.relevantPeriod overlaps "Measurement Period")
  or exists(["Medication": "VSAC; Warfarin"] M
    where M.relevantPeriod overlaps "Measurement Period")
  or exists(["Diagnosis": "VSAC; Thrombocytopenia"]
    where M.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exception 5: 4086F-2P"
/*
* config_link_id: denominator_exception_5
* Exception 5: patient declined treatment with aspirin or clopidogrel
*/
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4086F-2P"] P
    where P.revelvantPeriod starts during "Measurement Period")

define "Denominator Exception 6: 4086F-3P":
/*
* config_link_id:  denominator_exception_6
* Exception 6: Excepted for non-specified reason
*/
  exists(["Procedure, Performed": "MIPS; Denominator Exception: 4086F-3P"] P
    where P.revelvantPeriod starts starts during "Measurement Period")

define "Numerator Performance Not Met: 4086F-8P":
  /*
   * config_link_id: 4086F-8P
   * Numerator Performance Not Met for reasons not otherwise specified
   */
  not "Numerator Performance Met: 4086F"
  and not "Denominator Exception 1: 4086F-1P"
  and not "Denominator Exception 2: 4086F-2P"
  and not "Denominator Exception 3: 4086F-3P"
