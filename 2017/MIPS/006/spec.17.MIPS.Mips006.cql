library MIPS_006_2017 version '1'

/*
 * Source: MIPS
 * ID: 006
 * Year: 2017
 * Version: 1
 */

using QDM

// Able custom value sets

valueset "Able; Patient Refusal"
valueset "Able; System Reason"

valueset "MIPS; MIPS 006 Encounter"
valueset "MIPS; CAD Diagnosis"
valueset "MIPS; Denominator Exception: 4086F-1P"
valueset "MIPS; Denominator Exception: 4086F-2P"
valueset "MIPS; Denominator Exception: 4086F-3P"
valueset "MIPS; Performance Met: 4086F"
valueset "MIPS; Performance Not Met: 4086F-8P"
valueset "MIPS; Telehealth Modifier"

// Value Sets from VSAC

valueset "VSAC; Aspirin and Other Antiplatelet Agents": '2.16.840.1.113883.6.88'
valueset "VSAC; Medical Reason": '2.16.840.1.113883.3.526.3.1007'
valueset "VSAC; Thrombocytopenia": '2.16.840.1.113762.1.4.1045.45'
valueset "VSAC; Patient Reason Refused": '2.16.840.1.113883.3.600.1.1503'
valueset "VSAC; System Reason": '2.16.840.1.113883.3.526.3.1009'

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Patient Age at Encounter":
  AgeInYearsAt(
    ["Encounter, Performed": "MIPS; MIPS 006 Encounter"] E
        where E.relevantPeriod starts during "Measurement Period"
      and E.signingProvider.pqrsProvider = true
  )

define "Denominator":
  "Patient Age at Encounter" >= 18


define "Numerator Performance Met: 4086F":
  /*
   * config_link_id: 4086F
   */
  exists (["Medication, Order": "VSAC; Aspirin and Other Antiplatelet Agents"] M
    where M.relevantPeriod starts during "Measurement Period")
  or exists(["Procedure, Performed": "MIPS; Performance Met: 4086 F"] P
    where M.relevantPeriod starts during "Measurement Period")

//patient excepted because of non-specific reason
define "Denominator Exception: 4086F-1P":
/*
 * config_link_id: denominator_exception_1
 */
 exists (["Procedure, Performed": "MIPS; Denominator Exception: 4086-1P"] P
    where M.relevantPeriod starts before end of "Measurement Period")

//Exception 1: patient is excepted from the denominator if the presence of drug allergy or intolerance is documented
define "Denominator Exception 1: 4086F-1P":
/*
 * config_link_id: denominator_exception_1
 */
  exists (["Medication, Active": 416098002 in "VSAC; Medical Reason"] M //d/t allergy
    where M.relevantPeriod starts before end of "Measurement Period")
  or exists (["Medication, Active": 59037007 in "VSAC; Medical Reason"] M //d/t intolerace
    where M.relevantPeriod starts before end of "Measurement Period")


//Exception 2: patient is excepted because of the presence of another Thienopyridine agent or Warfarin therapy
define "Denominator Exception 2: 4086F-1P"
 /*
  * config_link_id: denominator_exception_2
  */
  exists([Medication, Active: "VSAC; Aspirin and Other Antiplatelet Agents"] M
    where M.relevantPeriod starts before end of "Measurement Period")


//Exception 3: patient is excepted because of a pre-existing bleeding disorder (thrombocytopenia)
define "Denominator Exception 3: 4086F-1P"
 /*
  * config_link_id: denominator_exception_3
  */
  exists([Diagnosis, Active: "VSAC; Thrombocytopenia"]
    where M.relevantPeriod starts before end of "Measurement Period")

//Exception 4: patient declined treatment with aspirin or clopidogrel
define "Denominator Exception 4: 4086F-2P"
/*
* config_link_id: denominator_exception_4
*/
  exists(["Patient, refusal": '105480006' in "VSAC; Patient Reason Refused"] P
    where P.revelvantPeriod starts before end of "Measurement Period")
  or exists(["Patient, refusal": "MIPS; Patient Refusal"] P
    where P.revelvantPeriod starts before end of "Measurement Period")

//Exception 5: documentation of system reason for not prescribing aspirin or clopidogrel (e.g., lack of drug availablility or other reasons attributable to the health care system)
define "Denominator Exception 5: 4086F-3P"
  /*
  * config_link_id: denominator_exception_5
  */
  exists(["Medication, not administered": "VSAC; System Reason"] M
    where P.revelvantPeriod starts before end of "Measurement Period")

//Exception 6: Excepted for non-specified reason
define "Denimonator Exception 6: 4086F-3P":
/*
* config_link_id:  denominator_exception_6
*/
  or exists(["Medication, not administered": "MIPS; Denominator Exception: 4086F-3P"]
    where P.revelvantPeriod starts before end of "Measurement Period")

//Numerator Performance Not Met for reasons not otherwise specified
define "Numerator Performance Not Met: 4086-8P":
  /*
   * config_link_id: numerator_performance_not_met
   */

  not "Numerator Performance Met: 4086F"
