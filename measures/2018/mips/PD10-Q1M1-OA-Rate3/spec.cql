library RADNET_PD10-Q1M1-OA_Rate_3_2018 version '2'

/*
 *
 * Source: RadNet
 * ID: PD10-Q1M1-OA
 * Rate: 3
 * Year: 2018
 * Version: 2
 * Written by: Steve Daniels
 *
  */

using QDM

// Custom value sets (Able)

valueset "Able; RadNet Advanced Image Testing Procedure"
valueset "Able; RadNet Patient Exclusion"
valueset "Able; Denominator Exception: GPD10N1X"
valueset "Able; Denominator Exception: GPD10N1Z"
valueset "Able; Performance Met: GPD10N1A"
valueset "Able; Performance Met: GPD10N1B"
valueset "Able; Performance Met: GPD10N1C"
valueset "Able; Performance Met: GPD10N1D"
valueset "Able; Performance Met: GPD10N1E"
valueset "Able; Performance Met: GPD10N2A"
valueset "Able; Performance Met: GPD10N2B"
valueset "Able; Performance Met: GPD10N2C"
valueset "Able; Performance Met: GPD10N2D"
valueset "Able; Performance Met: GPD10N3A"
valueset "Able; Performance Met: GPD10N3B"
valueset "Able; Performance Met: GPD10N3C"
valueset "Able; Performance Met: GPD10N3D"
valueset "Able; Performance Met: GPD10N3F"
valueset "Able; Performance Met: GPD10N3G"
valueset "Able; Performance Not Met: GPD10N3E"
valueset "Able; Performance Not Met: GPD10N3H"
valueset "Able; Performance Not Met: GPD10N3I"

parameter "Measurement Period" Interval<DateTime>

context Patient

define "Denominator Procedure":
  ["Procedure, Ordered": "Able; RadNet Advanced Image Testing Procedure"] P1
    where P1.relevantPeriod starts during "Measurement Period"
      and AgeInYearsAt(start of P1.relevantPeriod) >= 18
      and E.signingProvider.hasMeasureMembership = true

define "Rate 1 Performance Met":
  ["Procedure, Performed": "Able; Performance Met: GPD10N1A"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N1B"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N1C"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N1D"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N1E"]

define "Rate 1 Performance Met Exists":
  exists("Denominator Procedure" P1
    with "Rate 1 Performance Met" P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Rate 2 Performance Met":
  ["Procedure, Performed": "Able; Performance Met: GPD10N2A"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N2B"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N2C"]
  union ["Procedure, Performed": "Able; Performance Met: GPD10N2D"]

define "Rate 2 Performance Met Exists":
  exists("Denominator Procedure" P1
    with "Rate 1 Performance Met" P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

// Populations

define "Denominator":
  "Denominator Procedure"

define "Denominator Exclusion: GPD10D1A":
  // config_link_id: GPD10D1A
  exists(["Procedure, Performed": "Able; RadNet Patient Exclusion"] P
    where P.relevantPeriod starts during "Measurement Period")

define "Denominator Exclusion: GPD10N1X":
  // config_link_id: GPD10N1X
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Denominator Exception: GPD10N1X"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)
  or exists("Denominator Procedure" P
    where P.statusReason in ["ACEXEL","ACFINC","ACINPREP","ACINSDENIE","ACLAB","ACNOTRANS","ACPCMKR","ACPOSPREG","ACPTWK","ACREFABN","ACWGHT","APATRESCH","BREASTHOLD","BRST US NOT NEED","CONTRAINDICATED","LABSOUT","LOSTINFLWUP","METALIMPLANT","MIMMAMMO","NOINVITEUSED","NOLABS","NOPHONE","NOPREP","PORTAL","UNCONTPT"])

define "Denominator Exclusion: GPD10N1Z":
  // config_link_id: GPD10N1Z
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Denominator Exception: GPD10N1Z"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)
  or exists("Denominator Procedure" P
    where P.statusReason in ["ACCLOSE","ACDOWN","ACEMPER","ACEXELINT","ACNONPAR","ACNOPREAUT","ACREFER","ACWEATH","ADWEATHAUTOCONFIR","DUP","EMR ORDER","EORDER","EXPIRED","EORDER INCORRECT","EQUIP. EQUIPDOWN","NOREF","ORDERNOTUSED","OTCCC","OTCD","OTCSP","P4P","REFCNX","SYSTEST","TESTING","UMREVIEW"])

define "Numerator Performance Met: GPD10N3A":
  // config_link_id: GPD10N3A
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3A"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)
  and "Rate 1 Performance Met Exists"
  and "Rate 2 Performance Met Exists"

define "Numerator Performance Met: GPD10N3B":
  // config_link_id: GPD10N3B
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3B"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)
  and "Rate 1 Performance Met Exists"
  and "Rate 2 Performance Met Exists"

define "Numerator Performance Met: GPD10N3C":
  // config_link_id: GPD10N3C
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3C"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)
  and "Rate 1 Performance Met Exists"
  and "Rate 2 Performance Met Exists"

define "Numerator Performance Met: GPD10N3D":
  // config_link_id: GPD10N3D
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3D"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)
  and "Rate 1 Performance Met Exists"
  and "Rate 2 Performance Met Exists"

define "Numerator Performance Met: GPD10N3F":
  // config_link_id: GPD10N3F
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3F"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)
  and "Rate 1 Performance Met Exists"
  and "Rate 2 Performance Met Exists"

define "Numerator Performance Met: GPD10N3G":
  // config_link_id: GPD10N3G
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3G"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)
  and "Rate 1 Performance Met Exists"
  and "Rate 2 Performance Met Exists"

define "Numerator Performance Not Met: GPD10N3E":
  // config_link_id: GPD10N3E
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3E"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD10N3H":
  // config_link_id: GPD10N3H
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3H"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)

define "Numerator Performance Not Met: GPD10N3I":
  // config_link_id: GPD10N3I
  exists("Denominator Procedure" P1
    with ["Procedure, Performed": "Able; Performance Met: GPD10N3I"] P2
      such that P2.relevantPeriod starts during P1.relevantPeriod)
  or exists("Denominator Procedure" P
    where P.statusReason in ["ACNORESPONSE","ACNOSHOW","ACOTHR","ACPTSCK","ACRADCX","ACWLKDOUT","CLAUS","CLAUSTRO","PTLATE","PTREF"])

define "Numerator Performance Not Met: Procedure Not Completed":
  // config_link_id: not_completed
  exists("Denominator Procedure" P
    where P.status not in ["Void","OrderCancelled","PendingCancellation","Cancelled","Discontinued"])

define "Numerator Data Incomplete":
  // config_link_id: incomplete
  not "Denominator Exclusion: GPD10D1A"
  not "Denominator Exclusion: GPD10N1X"
  not "Denominator Exclusion: GPD10N1Z"
  and not "Numerator Performance Met: GPD10N3A"
  and not "Numerator Performance Met: GPD10N3B"
  and not "Numerator Performance Met: GPD10N3C"
  and not "Numerator Performance Met: GPD10N3D"
  and not "Numerator Performance Met: GPD10N3F"
  and not "Numerator Performance Met: GPD10N3G"
  and not "Numerator Performance Not Met: GPD10N3E"
  and not "Numerator Performance Not Met: GPD10N3H"
  and not "Numerator Performance Not Met: GPD10N3I"
  and not "Numerator Performance Not Met: Procedure Not Completed"
