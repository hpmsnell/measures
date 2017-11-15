library MIPS_141_2017 version '1'

/*
 * Source: MIPS
 * ID: 141
 * Year: 2017
 * Version: 1
 * Author: Steve Daniels
 *
  */

using QDM

// MIPS Custom Value Sets

valueset "MIPS; MIPS 141 Encounter"
valueset "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG) Left Eye"
valueset "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG) Right Eye"
valueset "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG) Bilateral"
valueset "MIPS; Performance Met: 3284F"
valueset "MIPS; Performance Met: 3285F"
valueset "MIPS; Performance Met: 0517F"
valueset "MIPS; Performance Not Met: 0517F-8P"
valueset "MIPS; Performance Not Met: 3284F-8P"

// Able value sets

valueset "Able; IOP Left Eye"
valueset "Able; IOP Right Eye"

parameter "Measurement Period" Interval<DateTime>
parameter "Denominator Period" Interval<DateTime>

context Patient

define "POAG":
  ["Diagnosis": "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG) Left Eye"]
  union ["Diagnosis": "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG) Right Eye"]
  union ["Diagnosis": "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG) Bilateral"]

define "POAG Left Eye":
  ["Diagnosis": "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG) Left Eye"]
  union ["Diagnosis": "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG) Bilateral"]

define "POAG Right Eye":]
  ["Diagnosis": "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG) Right Eye"]
  union ["Diagnosis": "MIPS; MIPS 141 Primary Open-Angle Glaucoma (POAG) Bilateral"]

define "Patient Age at Encounter":
  ["Encounter, Performed": "MIPS; MIPS 141 Encounter"] E
    where E.relevantPeriod starts during "Denominator Period"
      and not E.code.modifier in {'GQ', 'GT'}
      and AgeInYearsAt(start of E.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true
    with "POAG" D
      such that D.prevalencePeriod overlaps E.relevantPeriod

define "IOP Left Eye":
  ["Assessment, Peformed": "Able; IOP Left Eye"] P
    where P.relevantPeriod starts during "Measurement Period"

define "IOP Right Eye":
  ["Assessment, Peformed": "Able; IOP Right Eye"] P
    where P.relevantPeriod starts during "Measurement Period"

define "IOP Left Eye Delta":
  Last("IOP Left Eye") - First("IOP Left Eye")

define "IOP Left Eye Decreased by >= 15%":
  exists("POAG Left Eye" D
    where D.relevantPeriod overlaps "Denominator Period")
  and "IOP Left Eye Delta" / First("IOP Left Eye") <= -0.15

define "IOP Right Eye Decreased by >= 15%":
  exists("POAG Right Eye" D
    where D.relevantPeriod overlaps "Denominator Period")
  and "IOP Right Eye Delta" / First("IOP Right Eye") <= -0.15

define "IOP Left Eye Decreased by < 15%":
  exists("POAG Left Eye" D
    where D.relevantPeriod overlaps "Denominator Period")
  and "IOP Left Eye Delta" / First("IOP Left Eye") > -0.15

define "IOP Right Eye Decreased by < 15%":
  exists("POAG Right Eye" D
    where D.relevantPeriod overlaps "Denominator Period")
  and "IOP Right Eye Delta" / First("IOP Right Eye") > -0.15

define "IOP Decreased by < 15%":
  exists(["Procedure, Performed": "MIPS; Performance Met: 3285F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "IOP Left Eye Decreased by < 15%"
  or "IOP Right Eye Decreased by < 15%"

define "Denominator":
  exists("Denominator Encounter")

define "Numerator Performance Met: 3284F":
  /*
   * config_link_id: 3284F
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3284F"] P
    where P.relevantPeriod starts during "Measurement Period")
  or "IOP Left Eye Decreased by >= 15%"
  or "IOP Right Eye Decreased by >= 15%"

define "Numerator Performance Met: 3285F/0517F":
  /*
   * config_link_id: 3285F-0517F
   */
  "IOP Decreased by < 15%"
  and exists(["Procedure, Performed": "MIPS; Performance Met: 0517F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3285F/0517F-8P":
  /*
   * config_link_id: 3285F-0517F-8P
   */
  exists(["Procedure, Performed": "MIPS; Performance Met: 3285F"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Numerator Performance Not Met: 3284F-8P":
  /*
   * config_link_id: 3284F-8P
   */
  "Numerator Performance Met: 3284F"
  and "Numerator Performance Met: 3285F/0517F"
  and "Numerator Performance Not Met: 3285F/0517F-8P"
