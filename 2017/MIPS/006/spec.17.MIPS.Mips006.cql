library MIPS_006_2017 version '1'

/*
 * Source: MIPS
 * ID: 006
 * Year: 2017
 * Version: 1
 */

using QDM

// Able custom value sets

valueset "Able; Other Thienopyridine Agent"
valueset "Able; Aspirin and Clopidogrel"
valueset "Able; Warfarin Therapy"

valueset "MIPS; MIPS 006 Encounter"
valueset "MIPS; Telehealth Modifier"
valueset "MIPS; Coronary Artery Disease (CAD)"
valueset "MIPS; Denominator Exception: 4086F-1P"
valueset "MIPS; Patient Refusal Reason: 4086F-2P"
valueset "MIPS; Denominator Exception: 4086F-3P"
valueset "MIPS; Performance Met: 4086F"
valueset "MIPS; Performance Not Met: 4086F-8P"


// Value Sets from VSAC

valueset "VSAC; Thrombocytopenia": '2.16.840.1.113762.1.4.1045.45'
valueset "VSAC; Warfarin": '2.16.840.1.113883.3.117.1.7.1.232'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  AgeInYearsAt(
    ["Encounter, Performed": "MIPS; MIPS 006 Encounter"] E
        where E.relevantPeriod starts during "Measurement Period"
          and not E.code.modifier "MIPS; Telemedicine Modifier"
          and E.signingProvider.pqrsProvider = true
  )

define "Denominator":
  "Patient Age at Encounter" >= 18
  and exists(["Diagnosis": "MIPS; Coronary Artery Disease (CAD)"] D
    where D.prevalencePeriod overlaps "Measurement Period")

define "Numerator Performance Met: 4086F":
  /*
   * config_link_id: 4086F
   */
  exists (["Medication, Order": "Able; Aspirin and Clopidogrel"] M
    where M.authorDateTime during "Measurement Period")
  or exists (["Medication, Active": "Able; Aspirin and Clopidogrel"] M
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

define "Denominator Exception 2: 4086F-1P":
/*
 * config_link_id: denominator_exception_2
 * Exception 2: patient is excepted from the denominator if the presence of drug allergy or intolerance is documented
 */
  exists (["Allergy/Intolerance": "Able; Aspirin and Clopidogrel"] A
    where A.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exception 3: 4086F-1P"
 /*
  * config_link_id: denominator_exception_3
  * Exception 3: patient is excepted because of the presence of another Thienopyridine agent or Warfarin therapy
  */
  exists(["Medication, Order": "Able; Other Thienopyridine Agent"] M
    where M.authorDateTime during of "Measurement Period")
  or exists(["Medication, Active": "Able; Other Thienopyridine Agent"] M
    where M.relevantPeriod overlaps "Measurement Period")
<<<<<<< HEAD
  or exists(["Medication, Order": "VSAC; Warfarin"] M
    where M.authorDateTime during of "Measurement Period")
  or exists(["Medication, Active": "VSAC; Warfarin"] M
    where M.relevantPeriod overlaps "Measurement Period")
=======
  or exists(["Medication, Order": "Able; Warfarin Therapy"] M
      where M.authorDateTime during of "Measurement Period")
  or exists(["Medication, Active": "Able; Warfarin Therapy"] M
      where M.relevantPeriod overlaps "Measurement Period")

    //add warfarin to a new valueset and inlude
>>>>>>> origin/MIPS-006-2

define "Denominator Exception 4: 4086F-1P"
 /*
  * config_link_id: denominator_exception_4
  * Exception 4: patient is excepted because of a pre-existing bleeding disorder (thrombocytopenia)
  */
  exists(["Diagnosis, Active": "VSAC; Thrombocytopenia"]
    where M.prevalencePeriod overlaps "Measurement Period")

define "Denominator Exception 5: 4086F-2P"
/*
* config_link_id: denominator_exception_5
* Exception 5: patient declined treatment with aspirin or clopidogrel
*/
  exists(["Procedure, Performed": "MIPS; Patient Refusal Reason: 4086F-2P"] P
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
  and not "Denominator Exception 2: 4086F-1P"
  and not "Denominator Exception 3: 4086F-1P"
  and not "Denominator Exception 4: 4086F-1P"
  and not "Denominator Exception 5: 4086F-2P"
  and not "Denominator Exception 6: 4086F-3P"
