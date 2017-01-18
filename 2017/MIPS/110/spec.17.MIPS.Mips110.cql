library MIPS_110_2017 version '1'

/*
 * Source: MIPS
 * ID: 110
 * Year: 2017
 * Version: 1
 * Clinical Lead: Calvin Newman
 *
 */

using QDM

// VSAC Value Sets

valueset "Encounter, Performed: MIPS; MIPS 110 Encounters Set A"
valueset "Encounter, Performed: MIPS; MIPS 110 Encounters Set B"
valueset "Immunization, Administered: Influenza Vaccine"

"Communication: From Patient to Provider: Influenza Vaccination Declined" using "Influenza Vaccination Declined Grouping Value Set (2.16.840.1.113883.3.526.3.1255)"
"Communication: From Patient to Provider: Previous Receipt of Influenza Vaccine" using "Previous Receipt of Influenza Vaccine Grouping Value Set (2.16.840.1.113883.3.526.3.1185)"
"Diagnosis: Allergy to Eggs" using "Allergy to Eggs Grouping Value Set (2.16.840.1.113883.3.526.3.1253)"
"Diagnosis: Allergy to Influenza Vaccine" using "Allergy to Influenza Vaccine Grouping Value Set (2.16.840.1.113883.3.526.3.1256)"
"Diagnosis: Intolerance to Influenza Vaccine" using "Intolerance to Influenza Vaccine Grouping Value Set (2.16.840.1.113883.3.526.3.1257)"

"Immunization, Administered not done: Medical Reason" using "Medical Reason Grouping Value Set (2.16.840.1.113883.3.526.3.1007)"
"Immunization, Administered not done: Patient Reason" using "Patient Reason Grouping Value Set (2.16.840.1.113883.3.526.3.1008)"
"Immunization, Administered not done: System Reason" using "System Reason Grouping Value Set (2.16.840.1.113883.3.526.3.1009)"
"Immunization, Allergy: Influenza Vaccine" using "Influenza Vaccine Grouping Value Set (2.16.840.1.113883.3.526.3.1254)"
"Immunization, Intolerance: Influenza Vaccine" using "Influenza Vaccine Grouping Value Set (2.16.840.1.113883.3.526.3.1254)"

"Procedure, Intolerance: Influenza Vaccination" using "Influenza Vaccination Grouping Value Set (2.16.840.1.113883.3.526.3.402)"
"Procedure, Performed: Hemodialysis" using "Hemodialysis Grouping Value Set (2.16.840.1.113883.3.526.3.1083)"
"Procedure, Performed: Influenza Vaccination" using "Influenza Vaccination Grouping Value Set (2.16.840.1.113883.3.526.3.402)"
"Procedure, Performed: Peritoneal Dialysis" using "Peritoneal Dialysis Grouping Value Set (2.16.840.1.113883.3.526.3.1084)"
"Procedure, Performed not done: Medical Reason" using "Medical Reason Grouping Value Set (2.16.840.1.113883.3.526.3.1007)"
"Procedure, Performed not done: Patient Reason" using "Patient Reason Grouping Value Set (2.16.840.1.113883.3.526.3.1008)"
"Procedure, Performed not done: System Reason" using "System Reason Grouping Value Set (2.16.840.1.113883.3.526.3.1009)"
Supplemental Data Elements
"Encounter, Performed: Office Visit"
"Encounter, Performed: Outpatient Consultation"
"Encounter, Performed: Care Services in Long-Term Residential Facility"
"Encounter, Performed: Home Healthcare Services"
"Encounter, Performed: Patient Provider Interaction"
during "Measurement Period"

context Patient

parameter "Measurement Period A"
  default interval{@2016-01-01T00:00:00.0, @2016-03-31T00:00:00.0)

parameter "Measurement Period B"
  default interval(@2016-10-01T00:00:00.0, @2017-01-01T00:00:00.0)

define "Denominator"
/*
* metadata_identifier_link: dennominator
*/
  AgeInYearsAt(start of "Measurement Period") >= 6 months
  and (["Encounter, Performed": "MIPS; MIPS 110 Encounters"] Ea
    count = 2;
    where Ea.relevantPeriod starts during "Measurement Period A")
  And exists(["Encounter Performed": "MIPS; MIPS 110 Encounters"] Eb
    count = 1;
    where Eb.relevantPeriod starts during "Measurement Period B")
      and not exists([TELEHEALTH MODIFIER: GQ, GT***])


define "Numerator Performance Met: G8482"
  /*
   * metadata_identifier_link: G8482
   */
    exists([Immunization, Administered: Influenza Vaccine"] P where P.relevantPeriod during "Measuremenet Period"
    )

define "Numerator Performance Not Met: G8484"
      /*
       * metadata_identifier_link: G8484
       */

        exists([Immunization, Administered: Influenza Vaccine"] P where P.relevantPeriod during "Measuremenet Period"
        )

  define "Denominator Exception"
    /*
     * metadata_identifier_link: Denominator_Exclusion
     */
    exists(["Procedure, Performed": "MIPS; History of Bilateral Mastectomy: G9708"] P
      where P.relevantPeriod starts before end "Measurement Period")
    or exists(["Procedure, Performed": "VSAC; Bilateral Mastectomy"] P
      where P.relevantPeriod starts before end "Measurement Period")




  define "Denominaor Exclusion 2"
    /*
     * metadata_identifier_link: denominator_exclusion_2
     */
     (
       exists(["Procedure, Performed": "VSAC; Left Mastectomy"] P
        where P.relevantPeriod starts before end "Measurement Period")
       and exists(["Procedure, Performed": "VSAC; Right Mastectomy"] P
        where P.relevantPeriod starts before end "Measurement Period")
     ) or (
       exists(["Diagnosis": "VSAC; Left Mastectomy"] D
        where D.prevalencePeriod starts before end "Measurement Period")
       and exists(["Diagnosis": "VSAC; Right Mastectomy"] D
        where D.prevalencePeriod starts before end "Measurement Period")
     )



  define "Denominator Exclusion 3"
    /*
     * metadata_identifier_link: denominator_exclusion_2
     */
    exists([Intervention, Performed: "VSAC; Palliative Care"] I
      where I.relevantPeriod overlaps "Measurement Period")
    or exists([Intervention, Performed: "MIPS; Hospice Service: G9687"] I
      where I.relevantPeriod overlaps "Measurement Period")
